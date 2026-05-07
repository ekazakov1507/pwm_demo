set repo_root "C:/Users/user/VivadoProjects/2018-3/pwm_demo"
set report_dir [file join $repo_root build reqp1840_project_check]

file mkdir $report_dir

open_project [file join $repo_root pwm_demo.xpr]
reset_run Z7-LITE_impl
reset_run Z7-LITE
launch_runs Z7-LITE_impl -to_step route_design -jobs 4
wait_on_run Z7-LITE_impl
open_run Z7-LITE_impl

report_drc -file [file join $report_dir reqp1840_impl_drc.rpt]
report_timing_summary -file [file join $report_dir reqp1840_impl_timing_summary.rpt]
report_utilization -file [file join $report_dir reqp1840_impl_utilization.rpt]
