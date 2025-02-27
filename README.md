# PWM demo
Тестовый проект, 2 симметричного ШИМ с частотой 1 МГц. Модулируется гармоническое колебание с частотой 100 кГц.

## ПО
Xilinx Vivado 2018.3\
Octave (9.0.2).

## TO DO
* **Имплементация:**
    * Критически предупреждения. Невыполнение требований пол задержкам для z7020.
* **Файлы ограничений для плат**
    * xdc для MYiR z7020.

## Используемые отладочные платы
[Zybo Z7](https://digilent.com/reference/programmable-logic/zybo-z7/start)\
[Microphase-Z7-Lite](https://github.com/hw/Microphase-Z7-Lite)\
[MYiR Z-turn Board V2](https://www.myirtech.com/list.asp?id=708)

## Структура проекта
Octave, для тестирования
```
├── cos_table.txt // таблица косинуса
├── table_cos.m // формирование таблицы косинуса
├── pwm_platform.m // основной файл
├── pwm_l.m // ассиметричный (левый) ШИМ НЕ ИСПОЛЬЗУЕТСЯ
└── pwm_c.m // симметричный (центрированный) ШИМ
```

Vivado
```
pwm_demo_z7010-z7020
├── src
│   ├── cos_table_gen.vhd // таблица значений косинуса
│   ├── pwm_platform.vhd // верхний уровень
│   ├── pwm_l.vhd // ассиметричный (левый) ШИМ НЕ ИСПОЛЬЗУЕТСЯ
│   ├── pwm_c.vhd // симметричный (центрированный) ШИМ
├── tb
│   ├── tb_pwm_platform.vhd // test bench
├── ip
│   ├── dds_compiler_0 // генератор тестового синуса НЕ ИСПОЛЬЗУЕТСЯ
└──
```

## Описание ШИМ-модулятора
Текущая версия 2.

## 3 версия. ШИМ второго рода
В разработке.

## 2 версия. Модулируемый сигнал подстраивается под опорный
Начальные допущения.
* Счетчик опорного сигнала (треугольного или пилообразного) имеет инкремент равный единице и только единице. 
* Разрешение ШИМ 7 бит, значения опорного счетчика 0 - 127.
* Требуемая частота ШИМ 1МГц.

Соответственно, модулируемый сигнал подстраивается под опорный в случае для DDS. При формировании из таблицы в Octave создается таблица значений косинуса, занимающая 0.9 от диапазона значений опорного счетчика, т.е 6 - 122.

Для получения ШИМ 1 МГц необходимо.

$$f_{clk} = f_{PWM} \cdot 2 \cdot PWM_{Levels} = 1 \cdot 10^6 \cdot 2 \cdot 128 = 256\, МГц$$

Тактовая частота в $f_{clk}$ 256 МГц (128 в случае пилообразной опоры) требует использования дробных значений делителей в блоке ММСМ, но ММСМ поддерживает только целые значения делителей. Фактическая тактовая частота устанавливается 250 МГц. Тогда реальная частоты ШИМ 0.9765 МГц (1.02 мкс).

Формирование таблицы, содержащей значения половины периода косинуса с частотой $f_0$ 100 кГц потребует:

$$NTAB = \frac{f_{clk}}{2 \cdot f_0} = \frac{250 \cdot 10^6}{2 \cdot 1 cdot 10^5} = 1250\, значений$$

Диапазон значений в таблице косинуса равен 0.9 от диапазона значений опорного счетчика. Значения в таблице имеют то же разрешения, что сигнал счетчика, т.е. 7 бит. Таблица может быть сокращена с учетом того, что сигналы имеют низкое разрешение и многие значения в таблице повторяются.

## 1 версия. Опорный сигнал подстраивается под модулируемый
* Тактовая частота 100 МГц, период 10 нс (плоская вершина 5 нс).
* Разрешение тестового сигнала и опорного (счетчика для ШИМ) сигналов 16 бит (0 - 65535).
* Частота опорного сигнала из dds compiler'а - 15.258 кГц (точность настройки зависит также от установленной тактовой частоты).
* Разрешение и частоты ШИМ:

    | Инкремент | Частота ШИМ, МГц | Разрешение, бит | 
    |---|---|---|
    | 1 | 0.001525 | 15.9 |
    | 3 | 0.004577 | 14.4 |
    | 5 | 0.007629 | 13.7 |
    | 51 | 0.077821 | 10.3 |
    | 255 | 0.389105 | 8.0 |
    | 771 | 1.176470 | 4.4 |

**Пояснение к таблице**

Разрешение сигналов по 16 бит. Возможный диапазон значений от 0 до 65535. Тогда, чтобы иметь целые кратные шаги опорного сигнала в ШИМ необходимо делить 65535 нацело иначе потребуется сложный неточный код для подстройки опоры под модулируемый сигнал (как я делал в магистерской), или необходимо использовать числа с плавающей точкой.

Все делители числа 65 535: 
1, 3, 5, 15, 17, 51, 85, 255, 257, 771, 1285, 3855, 4369, 13107, 21845, 65535. 

Эти делители и есть инкременты для счетчика опорного сигнала. 

$$ PWM_{Levels} = \frac{2^R-1}{Increment} = \frac{2^{16} - 1 = 65535}{51} = 1285 $$

$$ f_{PWM} = \frac{f_{clk}}{PVM\_Levels} = \frac{100 \cdot 10^6}{1285} = 0.077821 = 77.8\, кГц $$

$$ PWM_{Resolution} = \log_2(PWM_{Levels}) = \log_2(1285) = 10.3\, бит $$






