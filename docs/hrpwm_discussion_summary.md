# HRPWM/MEP Discussion Summary

Этот файл кратко фиксирует выводы из диалога о возможности улучшить PWM-разрешение в текущем проекте `pwm_demo`.

## Исходный Контекст

В проекте уже есть обычный цифровой PWM на VHDL:

- `src/pwm_core/rtl/pwm/pwm_1ch.vhd` - один PWM-канал: счетчик, масштабирование входа, comparator, complementary outputs.
- `src/pwm_core/rtl/pwm/pwm_mch.vhd` - multi-channel wrapper.
- `src/pwm/pwm_mch_buf.vhd` - buffered PWM path с FIFO, переходом между `clk` и `clk_pwm`, runtime post-divider.
- `src/utils/pwm_clk_post_scaler.vhd` - выбирает tick enable `/2`, `/4`, `/8`, `/16`.
- `src/main.vhd` - top-level: raw `clk_pwm = 200 MHz`, build-time `pwm_resolution_bits`, runtime divider button.

Текущая формула для симметричного PWM:

```text
pwm_frequency = raw_clk_pwm_hz / (post_divider * 2 * 2**pwm_resolution_bits)
```

Для текущего raw `clk_pwm = 200 MHz`:

```text
pwm_frequency = 200 MHz / (post_divider * 2 * 2**pwm_resolution_bits)
```

## Что Было В PDF TI HRPWM

Были просмотрены страницы 7-10 из `spru924f.pdf` про TI HRPWM.

Ключевая идея TI HRPWM:

- обычный PWM остается coarse-базой;
- HRPWM добавляет fine edge positioning через MEP;
- MEP дробит один coarse system clock на более мелкие edge positions;
- управление duty идет через `CMPAHR`, управление phase - через `TBPHSHR`;
- эти HR-регистры выглядят как 8-битные расширения к обычным coarse-регистрам;
- нужен `MEP scale factor`, потому что реальное число MEP steps на один coarse tick зависит от железа и калибровки.

Важный вывод: TI HRPWM - это не просто больше бит в расчетах. Это физическое смещение фронта внутри одного clock tick.

## Главный Вывод

Текущий PWM не является HRPWM в TI-смысле. Он обычный counter/comparator PWM, и финальное deterministic-разрешение ограничено тем, сколько физических edge positions доступно на выходном пине.

Если мы просто расширим duty value с 8 до 10 или 12 бит, но фронт все равно может переключаться только по фронтам `clk_pwm`/`tick_ce`, финальное single-period разрешение на пине не улучшится.

Разделение понятий:

- **математическое разрешение** - сколько бит хранится в duty/sample;
- **финальное физическое разрешение** - сколько реальных временных позиций может занять фронт PWM на пине.

Нужно улучшать именно второе.

## Можно Ли Улучшить Разрешение С Тем Же 200 MHz

Да, но только если есть неиспользованные raw `clk_pwm` slots внутри coarse PWM tick.

Идея raw-clock HR режима:

```text
fine_slots = post_divider
extra_bits = log2(fine_slots)
```

Для текущих runtime dividers:

| Runtime divider | Raw slots inside coarse tick | Extra deterministic bits |
|-----------------|------------------------------|--------------------------|
| `/2` | 2 | +1 bit |
| `/4` | 4 | +2 bits |
| `/8` | 8 | +3 bits |
| `/16` | 16 | +4 bits |

Пример:

```text
r = 5, divider /4
coarse levels = 2**5 = 32
fine slots = 4
effective levels = 32 * 4 = 128 = 2**7
```

То есть 5-bit coarse PWM может вести себя как примерно 7-bit effective PWM, если coarse tick специально идет через `/4`, а фронт потом досчитывается raw clock slots.

Но это не магия: мы меняем структуру генерации фронта, а не создаем sub-clock MEP.

## Где Улучшение Невозможно Без Специального Железа

Если частота и разрешение уже используют всю сетку raw `clk_pwm`, свободных slots нет.

Пример из обсуждения:

```text
PWM frequency = 200 MHz / (2 * 256) = 390.625 kHz
resolution = 8 bits
```

Это означает:

```text
PWM period = 2.56 us
raw 200 MHz tick = 5 ns
ticks per PWM period = 512
center-aligned period ticks = 2 * 256
```

В таком режиме все 512 raw ticks уже заняты обычным 8-bit center-aligned PWM. Улучшить deterministic single-period resolution обычной FPGA-логикой при том же `200 MHz` нельзя.

Если сделать:

```text
7-bit coarse + 2 fine slots
```

то получится:

```text
128 * 2 = 256 levels
```

То есть снова 8 bits, а не 9. Мы просто обменяли coarse bit на fine bit.

## Что Не Стоит Делать

Не стоит делать "MEP" на обычных LUT/carry delay chains как основной метод. Такая задержка будет зависеть от:

- placement/routing;
- температуры;
- питания;
- версии synthesis/implementation;
- конкретного чипа.

Это может ухудшить результат и сделать поведение плохо повторяемым.

Также MMCM dynamic phase shift не выглядит хорошим методом для edge-by-edge PWM modulation. MMCM полезен для генерации стабильных clocks/phases, но не как быстрый per-edge MEP.

## Реалистичные Варианты Улучшения

### 1. Raw-Clock HR Mode

Самый практичный первый шаг.

Идея:

- оставить текущий coarse PWM;
- duty value расширить на fine bits;
- верхние биты идут в coarse comparator;
- нижние биты выбирают задержку фронта на `0..post_divider-1` raw `clk_pwm` cycles;
- complementary outputs и dead-time нужно обрабатывать аккуратно, чтобы не получить overlap.

Плюсы:

- не нужен внешний oscillator;
- не нужен настоящий MEP;
- работает с текущим 200 MHz MMCM clock;
- deterministic и хорошо симулируется.

Минусы:

- extra bits ограничены post-divider;
- при `/2` можно получить только +1 bit;
- если режим уже использует raw grid полностью, прироста нет.

### 2. OSERDESE2 / ODELAYE2

Это путь к более настоящему sub-clock edge positioning на Xilinx FPGA.

Возможности:

- `OSERDESE2` может формировать более мелкие временные позиции через serialization pattern;
- `ODELAYE2` может задерживать output edge, если выбранные pins/banks поддерживают нужный режим.

Нужно проверить:

- точный FPGA part и speed grade;
- доступность primitives на выбранных output pins/banks;
- constraints;
- timing;
- совместимость с complementary outputs и dead-time.

Для PWM-output важнее `ODELAY`, а не `IDELAY`: `IDELAY` в основном для input paths.

### 3. Dithering

Можно чередовать соседние duty values между периодами, чтобы улучшить среднее разрешение.

Плюсы:

- не требует специального IO;
- может улучшить average duty resolution.

Минусы:

- single-period PWM resolution не растет;
- появляется ripple/jitter/noise;
- для power electronics это может быть нежелательно.

## Нужен Ли Отдельный `hrpwm_core`

Рекомендация: не создавать отдельный `hrpwm_core` с нуля.

Лучше развивать существующий `pwm_core`:

```text
src/pwm_core/rtl/pwm/pwm_1ch.vhd
src/pwm_core/rtl/pwm/pwm_mch.vhd
```

и добавить optional HR-блоки:

```text
src/pwm_core/rtl/pwm/hrpwm_pkg.vhd
src/pwm_core/rtl/pwm/hr_edge_scheduler.vhd
```

Пример направления:

```text
hr_enable     : boolean
hr_fine_width : integer
hr_slots      : integer
```

Normal mode должен оставаться полностью прежним. HR mode должен использовать existing coarse comparator и добавлять fine edge scheduler.

Отдельный device-specific блок имеет смысл только позже, если будут добавлены Xilinx primitives:

```text
xilinx_oserdes_hr_output.vhd
xilinx_odelay_hr_output.vhd
```

## Таблица Для 200 MHz Clock

Эта таблица была добавлена в `docs/console_build_guide.md`.

| Resolution (`pwm_resolution_bits`) | Runtime divider | PWM frequency |
|------------------------------------|-----------------|---------------|
| 5 | `/2` | 1.562500 MHz |
| 5 | `/4` | 781.250000 kHz |
| 5 | `/8` | 390.625000 kHz |
| 5 | `/16` | 195.312500 kHz |
| 6 | `/2` | 781.250000 kHz |
| 6 | `/4` | 390.625000 kHz |
| 6 | `/8` | 195.312500 kHz |
| 6 | `/16` | 97.656250 kHz |
| 7 | `/2` | 390.625000 kHz |
| 7 | `/4` | 195.312500 kHz |
| 7 | `/8` | 97.656250 kHz |
| 7 | `/16` | 48.828125 kHz |
| 8 | `/2` | 195.312500 kHz |
| 8 | `/4` | 97.656250 kHz |
| 8 | `/8` | 48.828125 kHz |
| 8 | `/16` | 24.414062 kHz |
| 9 | `/2` | 97.656250 kHz |
| 9 | `/4` | 48.828125 kHz |
| 9 | `/8` | 24.414062 kHz |
| 9 | `/16` | 12.207031 kHz |
| 10 | `/2` | 48.828125 kHz |
| 10 | `/4` | 24.414062 kHz |
| 10 | `/8` | 12.207031 kHz |
| 10 | `/16` | 6.103516 kHz |

## Console Build Examples

Resolution-specific bitstream builds:

```powershell
$Vivado = "C:\Xilinx\Vivado\2018.3\bin\vivado.bat"

cd C:\Users\user\VivadoProjects\2018-3\pwm_demo

# 5-bit firmware: 1.5625 MHz at /2, 781.25 kHz at /4, 390.625 kHz at /8.
& $Vivado -mode batch -source tcl\build_z7-lite.tcl -tclargs r5_pd2_16 "pwm_resolution_bits=5"

# 7-bit firmware: 390.625 kHz at /2, 195.3125 kHz at /4.
& $Vivado -mode batch -source tcl\build_z7-lite.tcl -tclargs r7_pd2_16 "pwm_resolution_bits=7"

# 8-bit firmware: current default resolution, explicit output tag.
& $Vivado -mode batch -source tcl\build_z7-lite.tcl -tclargs r8_pd2_16 "pwm_resolution_bits=8"

# 10-bit firmware: lower PWM frequency, higher duty resolution.
& $Vivado -mode batch -source tcl\build_z7-lite.tcl -tclargs r10_pd2_16 "pwm_resolution_bits=10"
```

Archive build metadata:

```powershell
python .\tools\manage_firmware_builds.py archive --bitstream-path .\bit\Z7_LITE\z7-lite-r7-pd2-16.bit --experiment r7_pd2_16 --board Z7_LITE --config-name r7_pd2_16 --generic-override pwm_resolution_bits=7 --build-param raw_clk_pwm_hz=200000000 --build-param post_divider_min=2 --build-param post_divider_max=16
python .\tools\manage_firmware_builds.py list
```

Package selected Z7-Lite bitstream into SD-card boot image:

```powershell
python .\tools\build_z7_lite_sd_boot.py --skip-bitstream --bitstream-path .\bit\Z7_LITE\z7-lite-r7-pd2-16.bit
```

## Short Practical Recommendation

Для текущего проекта лучше сначала оставить MEP в стороне и работать с обычными разрешениями/frequency tradeoffs.

Если позже возвращаться к HRPWM, первый разумный шаг - raw-clock HR scheduler внутри существующего `pwm_core`, а не отдельный новый core и не LUT-based pseudo-MEP.

Для настоящего прироста выше raw 200 MHz grid нужны Xilinx output primitives или внешний/более быстрый физический механизм edge positioning.
