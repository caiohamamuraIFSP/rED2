ed_1st.mod: ED2/ED/src/driver/ed_1st.o
ED2/ED/src/driver/ed_1st.o: ed_mem_alloc.mod ed_met_driver.mod ed_misc_coms.mod ed_para_coms.mod ed_state_vars.mod
ed_driver.mod: ED2/ED/src/driver/ed_driver.o
ED2/ED/src/driver/ed_driver.o: canopy_radiation_coms.mod consts_coms.mod detailed_coms.mod ed_init.mod ed_init_history.mod ed_met_driver.mod ed_misc_coms.mod ed_node_coms.mod ed_state_vars.mod fuse_fiss_utils.mod grid_coms.mod hrzshade_utils.mod lsm_hyd.mod phenology_aux.mod random_utils.mod soil_coms.mod update_derived_utils.mod
ed_met_driver.mod: ED2/ED/src/driver/ed_met_driver.o
ED2/ED/src/driver/ed_met_driver.o: canopy_air_coms.mod canopy_radiation_coms.mod consts_coms.mod ed_max_dims.mod ed_misc_coms.mod ed_node_coms.mod ed_state_vars.mod grid_coms.mod hdf5_utils.mod lapse.mod met_driver_coms.mod pft_coms.mod radiate_utils.mod random_utils.mod therm_lib.mod update_derived_utils.mod
ed_model.mod: ED2/ED/src/driver/ed_model.o
ED2/ED/src/driver/ed_model.o: average_utils.mod budget_utils.mod consts_coms.mod ed_init.mod ed_met_driver.mod ed_misc_coms.mod ed_node_coms.mod ed_state_vars.mod ed_type_init.mod edio.mod euler_driver.mod grid_coms.mod heun_driver.mod hybrid_driver.mod lsm_hyd.mod mem_polygons.mod radiate_driver.mod rk4_coms.mod rk4_driver.mod rk4_integ_utils.mod stable_cohorts.mod update_derived_utils.mod vegetation_dynamics.mod
bdf2_solver.mod: ED2/ED/src/dynamics/bdf2_solver.o
ED2/ED/src/dynamics/bdf2_solver.o: consts_coms.mod ed_misc_coms.mod ed_state_vars.mod ed_therm_lib.mod grid_coms.mod rk4_coms.mod soil_coms.mod therm_lib8.mod
canopy_struct_dynamics.mod: ED2/ED/src/dynamics/canopy_struct_dynamics.o
ED2/ED/src/dynamics/canopy_struct_dynamics.o: allometry.mod canopy_air_coms.mod canopy_layer_coms.mod consts_coms.mod ed_misc_coms.mod ed_state_vars.mod grid_coms.mod met_driver_coms.mod pft_coms.mod phenology_coms.mod physiology_coms.mod rk4_coms.mod soil_coms.mod
disturbance.mod: ED2/ED/src/dynamics/disturbance.o
ED2/ED/src/dynamics/disturbance.o: allometry.mod consts_coms.mod detailed_coms.mod disturb_coms.mod ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod ed_therm_lib.mod ed_type_init.mod forestry.mod fuse_fiss_utils.mod fusion_fission_coms.mod grid_coms.mod mem_polygons.mod met_driver_coms.mod mortality.mod pft_coms.mod phenology_aux.mod plant_hydro.mod stable_cohorts.mod therm_lib.mod update_derived_utils.mod
euler_driver.mod: ED2/ED/src/dynamics/euler_driver.o
ED2/ED/src/dynamics/euler_driver.o: budget_utils.mod consts_coms.mod ed_max_dims.mod ed_misc_coms.mod ed_para_coms.mod ed_state_vars.mod grid_coms.mod met_driver_coms.mod photosyn_driv.mod plant_hydro.mod rk4_coms.mod rk4_copy_patch.mod rk4_derivs.mod rk4_integ_utils.mod rk4_misc.mod soil_coms.mod soil_respiration.mod therm_lib.mod therm_lib8.mod update_derived_utils.mod
events.mod: ED2/ED/src/dynamics/events.o
ED2/ED/src/dynamics/events.o: allometry.mod consts_coms.mod disturbance.mod ed_misc_coms.mod ed_state_vars.mod ed_therm_lib.mod ed_type_init.mod fuse_fiss_utils.mod grid_coms.mod met_driver_coms.mod pft_coms.mod plant_hydro.mod rk4_integ_utils.mod stable_cohorts.mod therm_lib.mod update_derived_utils.mod
farq_katul.mod: ED2/ED/src/dynamics/farq_katul.o
ED2/ED/src/dynamics/farq_katul.o: consts_coms.mod ed_misc_coms.mod pft_coms.mod phenology_coms.mod physiology_coms.mod rk4_coms.mod therm_lib.mod
farq_leuning.mod: ED2/ED/src/dynamics/farq_leuning.o
ED2/ED/src/dynamics/farq_leuning.o: c34constants.mod consts_coms.mod pft_coms.mod phenology_coms.mod physiology_coms.mod rk4_coms.mod therm_lib8.mod
fire.mod: ED2/ED/src/dynamics/fire.o
ED2/ED/src/dynamics/fire.o: consts_coms.mod disturb_coms.mod ed_misc_coms.mod ed_state_vars.mod grid_coms.mod pft_coms.mod soil_coms.mod
forestry.mod: ED2/ED/src/dynamics/forestry.o
ED2/ED/src/dynamics/forestry.o: consts_coms.mod detailed_coms.mod disturb_coms.mod ed_max_dims.mod ed_state_vars.mod fuse_fiss_utils.mod
growth_balive.mod: ED2/ED/src/dynamics/growth_balive.o
ED2/ED/src/dynamics/growth_balive.o: allometry.mod budget_utils.mod consts_coms.mod ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod ed_therm_lib.mod fuse_fiss_utils.mod met_driver_coms.mod mortality.mod pft_coms.mod physiology_coms.mod plant_hydro.mod stable_cohorts.mod update_derived_utils.mod
heun_driver.mod: ED2/ED/src/dynamics/heun_driver.o
ED2/ED/src/dynamics/heun_driver.o: budget_utils.mod consts_coms.mod ed_max_dims.mod ed_misc_coms.mod ed_para_coms.mod ed_state_vars.mod grid_coms.mod met_driver_coms.mod photosyn_driv.mod plant_hydro.mod rk4_coms.mod rk4_copy_patch.mod rk4_derivs.mod rk4_integ_utils.mod rk4_misc.mod soil_coms.mod soil_respiration.mod therm_lib.mod therm_lib8.mod update_derived_utils.mod
hybrid_driver.mod: ED2/ED/src/dynamics/hybrid_driver.o
ED2/ED/src/dynamics/hybrid_driver.o: bdf2_solver.mod budget_utils.mod consts_coms.mod ed_misc_coms.mod ed_para_coms.mod ed_state_vars.mod grid_coms.mod met_driver_coms.mod photosyn_driv.mod plant_hydro.mod rk4_coms.mod rk4_copy_patch.mod rk4_derivs.mod rk4_integ_utils.mod rk4_misc.mod soil_coms.mod soil_respiration.mod therm_lib.mod therm_lib8.mod update_derived_utils.mod
lsm_hyd.mod: ED2/ED/src/dynamics/lsm_hyd.o
ED2/ED/src/dynamics/lsm_hyd.o: consts_coms.mod ed_misc_coms.mod ed_node_coms.mod ed_state_vars.mod grid_coms.mod hydrology_coms.mod hydrology_constants.mod pft_coms.mod soil_coms.mod therm_lib.mod
mortality.mod: ED2/ED/src/dynamics/mortality.o
ED2/ED/src/dynamics/mortality.o: consts_coms.mod disturb_coms.mod ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod pft_coms.mod
multiple_scatter.mod: ED2/ED/src/dynamics/multiple_scatter.o
ED2/ED/src/dynamics/multiple_scatter.o: canopy_radiation_coms.mod consts_coms.mod ed_max_dims.mod rk4_coms.mod
old_twostream_rad.mod: ED2/ED/src/dynamics/old_twostream_rad.o
ED2/ED/src/dynamics/old_twostream_rad.o: canopy_radiation_coms.mod consts_coms.mod ed_max_dims.mod rk4_coms.mod
phenology_aux.mod: ED2/ED/src/dynamics/phenology_aux.o
ED2/ED/src/dynamics/phenology_aux.o: allometry.mod consts_coms.mod ed_max_dims.mod ed_state_vars.mod ed_therm_lib.mod grid_coms.mod pft_coms.mod phenology_coms.mod physiology_coms.mod plant_hydro.mod soil_coms.mod stable_cohorts.mod therm_lib.mod
phenology_driv.mod: ED2/ED/src/dynamics/phenology_driv.o
ED2/ED/src/dynamics/phenology_driv.o: allometry.mod budget_utils.mod consts_coms.mod ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod ed_therm_lib.mod grid_coms.mod pft_coms.mod phenology_aux.mod phenology_coms.mod plant_hydro.mod stable_cohorts.mod therm_lib.mod
photosyn_driv.mod: ED2/ED/src/dynamics/photosyn_driv.o
ED2/ED/src/dynamics/photosyn_driv.o: allometry.mod canopy_air_coms.mod consts_coms.mod ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod farq_katul.mod farq_leuning.mod met_driver_coms.mod pft_coms.mod phenology_coms.mod physiology_coms.mod rk4_coms.mod soil_coms.mod therm_lib.mod
plant_hydro.mod: ED2/ED/src/dynamics/plant_hydro.o
ED2/ED/src/dynamics/plant_hydro.o: allometry.mod consts_coms.mod ed_misc_coms.mod ed_state_vars.mod grid_coms.mod pft_coms.mod physiology_coms.mod rk4_coms.mod soil_coms.mod
radiate_driver.mod: ED2/ED/src/dynamics/radiate_driver.o
ED2/ED/src/dynamics/radiate_driver.o: allometry.mod canopy_layer_coms.mod canopy_radiation_coms.mod consts_coms.mod ed_max_dims.mod ed_misc_coms.mod ed_para_coms.mod ed_state_vars.mod grid_coms.mod multiple_scatter.mod old_twostream_rad.mod radiate_utils.mod rk4_coms.mod soil_coms.mod twostream_rad.mod
reproduction.mod: ED2/ED/src/dynamics/reproduction.o
ED2/ED/src/dynamics/reproduction.o: allometry.mod consts_coms.mod ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod ed_therm_lib.mod ed_type_init.mod fuse_fiss_utils.mod fusion_fission_coms.mod grid_coms.mod mem_polygons.mod met_driver_coms.mod pft_coms.mod phenology_aux.mod phenology_coms.mod physiology_coms.mod plant_hydro.mod stable_cohorts.mod update_derived_utils.mod
rk4_copy_patch.mod: ED2/ED/src/dynamics/rk4_copy_patch.o
ED2/ED/src/dynamics/rk4_copy_patch.o: allometry.mod budget_utils.mod canopy_air_coms.mod canopy_struct_dynamics.mod consts_coms.mod disturb_coms.mod ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod ed_therm_lib.mod grid_coms.mod phenology_coms.mod physiology_coms.mod plant_hydro.mod rk4_coms.mod rk4_misc.mod soil_coms.mod therm_lib.mod therm_lib8.mod
rk4_derivs.mod: ED2/ED/src/dynamics/rk4_derivs.o
ED2/ED/src/dynamics/rk4_derivs.o: budget_utils.mod canopy_struct_dynamics.mod consts_coms.mod ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod grid_coms.mod pft_coms.mod physiology_coms.mod plant_hydro.mod rk4_coms.mod soil_coms.mod therm_lib8.mod
rk4_driver.mod: ED2/ED/src/dynamics/rk4_driver.o
ED2/ED/src/dynamics/rk4_driver.o: budget_utils.mod ed_misc_coms.mod ed_para_coms.mod ed_state_vars.mod grid_coms.mod met_driver_coms.mod photosyn_driv.mod plant_hydro.mod rk4_coms.mod rk4_copy_patch.mod rk4_integ_utils.mod rk4_misc.mod soil_respiration.mod therm_lib.mod update_derived_utils.mod
rk4_integ_utils.mod: ED2/ED/src/dynamics/rk4_integ_utils.o
ED2/ED/src/dynamics/rk4_integ_utils.o: c34constants.mod canopy_air_coms.mod canopy_layer_coms.mod canopy_radiation_coms.mod consts_coms.mod ed_max_dims.mod ed_misc_coms.mod ed_para_coms.mod ed_state_vars.mod grid_coms.mod hydrology_coms.mod physiology_coms.mod rk4_coms.mod rk4_copy_patch.mod rk4_derivs.mod rk4_misc.mod soil_coms.mod therm_lib8.mod
rk4_misc.mod: ED2/ED/src/dynamics/rk4_misc.o
ED2/ED/src/dynamics/rk4_misc.o: budget_utils.mod canopy_struct_dynamics.mod consts_coms.mod ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod ed_therm_lib.mod grid_coms.mod pft_coms.mod physiology_coms.mod plant_hydro.mod rk4_coms.mod soil_coms.mod therm_lib.mod therm_lib8.mod
soil_respiration.mod: ED2/ED/src/dynamics/soil_respiration.o
ED2/ED/src/dynamics/soil_respiration.o: budget_utils.mod consts_coms.mod decomp_coms.mod ed_misc_coms.mod ed_state_vars.mod farq_leuning.mod grid_coms.mod pft_coms.mod physiology_coms.mod rk4_coms.mod soil_coms.mod therm_lib.mod
structural_growth.mod: ED2/ED/src/dynamics/structural_growth.o
ED2/ED/src/dynamics/structural_growth.o: allometry.mod budget_utils.mod consts_coms.mod disturb_coms.mod ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod ed_therm_lib.mod fuse_fiss_utils.mod pft_coms.mod physiology_coms.mod plant_hydro.mod stable_cohorts.mod update_derived_utils.mod
twostream_rad.mod: ED2/ED/src/dynamics/twostream_rad.o
ED2/ED/src/dynamics/twostream_rad.o: canopy_radiation_coms.mod consts_coms.mod ed_max_dims.mod rk4_coms.mod
vegetation_dynamics.mod: ED2/ED/src/dynamics/vegetation_dynamics.o
ED2/ED/src/dynamics/vegetation_dynamics.o: average_utils.mod budget_utils.mod canopy_radiation_coms.mod consts_coms.mod disturbance.mod ed_cn_utils.mod ed_misc_coms.mod ed_state_vars.mod fire.mod fuse_fiss_utils.mod fusion_fission_coms.mod grid_coms.mod growth_balive.mod hrzshade_utils.mod mem_polygons.mod phenology_driv.mod reproduction.mod soil_respiration.mod structural_growth.mod update_derived_utils.mod
ed_bigleaf_init.mod: ED2/ED/src/init/ed_bigleaf_init.o
ED2/ED/src/init/ed_bigleaf_init.o: allometry.mod consts_coms.mod ed_max_dims.mod ed_node_coms.mod ed_state_vars.mod ed_type_init.mod fuse_fiss_utils.mod grid_coms.mod pft_coms.mod physiology_coms.mod
ed_init.mod: ED2/ED/src/init/ed_init.o
ED2/ED/src/init/ed_init.o: consts_coms.mod ed_bigleaf_init.mod ed_max_dims.mod ed_misc_coms.mod ed_nbg_init.mod ed_node_coms.mod ed_state_vars.mod ed_work_vars.mod grid_coms.mod landuse_init.mod mem_polygons.mod phenology_startup.mod rk4_coms.mod soil_coms.mod
ed_init_atm.mod: ED2/ED/src/init/ed_init_atm.o
ED2/ED/src/init/ed_init_atm.o: canopy_layer_coms.mod canopy_radiation_coms.mod canopy_struct_dynamics.mod consts_coms.mod ed_misc_coms.mod ed_node_coms.mod ed_para_coms.mod ed_state_vars.mod ed_therm_lib.mod fuse_fiss_utils.mod fusion_fission_coms.mod grid_coms.mod hrzshade_utils.mod met_driver_coms.mod soil_coms.mod stable_cohorts.mod therm_lib.mod update_derived_utils.mod
ed_nbg_init.mod: ED2/ED/src/init/ed_nbg_init.o
ED2/ED/src/init/ed_nbg_init.o: allometry.mod consts_coms.mod decomp_coms.mod ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod ed_type_init.mod fuse_fiss_utils.mod grid_coms.mod pft_coms.mod physiology_coms.mod
ed_params.mod: ED2/ED/src/init/ed_params.o
ED2/ED/src/init/ed_params.o: allometry.mod budget_utils.mod canopy_air_coms.mod canopy_layer_coms.mod canopy_radiation_coms.mod consts_coms.mod decomp_coms.mod detailed_coms.mod disturb_coms.mod ed_max_dims.mod ed_misc_coms.mod ed_therm_lib.mod farq_leuning.mod fusion_fission_coms.mod grid_coms.mod hydrology_coms.mod met_driver_coms.mod pft_coms.mod phenology_coms.mod physiology_coms.mod plant_hydro.mod rk4_coms.mod soil_coms.mod
ed_type_init.mod: ED2/ED/src/init/ed_type_init.o
ED2/ED/src/init/ed_type_init.o: allometry.mod canopy_air_coms.mod consts_coms.mod ed_cn_utils.mod ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod ed_therm_lib.mod grid_coms.mod pft_coms.mod phenology_coms.mod physiology_coms.mod plant_hydro.mod rk4_coms.mod soil_coms.mod therm_lib.mod
landuse_init.mod: ED2/ED/src/init/landuse_init.o
ED2/ED/src/init/landuse_init.o: consts_coms.mod detailed_coms.mod disturb_coms.mod ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod grid_coms.mod
phenology_startup.mod: ED2/ED/src/init/phenology_startup.o
ED2/ED/src/init/phenology_startup.o: ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod grid_coms.mod phenology_aux.mod phenology_coms.mod
average_utils.mod: ED2/ED/src/io/average_utils.o
ED2/ED/src/io/average_utils.o: consts_coms.mod ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod grid_coms.mod met_driver_coms.mod physiology_coms.mod soil_coms.mod therm_lib.mod
edio.mod: ED2/ED/src/io/edio.o
ED2/ED/src/io/edio.o: average_utils.mod ed_misc_coms.mod ed_print.mod ed_state_vars.mod grid_coms.mod
ed_init_history.mod: ED2/ED/src/io/ed_init_history.o
ED2/ED/src/io/ed_init_history.o: ed_max_dims.mod ed_misc_coms.mod ed_node_coms.mod ed_state_vars.mod fusion_fission_coms.mod grid_coms.mod hdf5_coms.mod landuse_init.mod phenology_startup.mod soil_coms.mod
ed_load_namelist.mod: ED2/ED/src/io/ed_load_namelist.o
ED2/ED/src/io/ed_load_namelist.o: canopy_air_coms.mod canopy_layer_coms.mod canopy_radiation_coms.mod consts_coms.mod decomp_coms.mod detailed_coms.mod disturb_coms.mod ed_max_dims.mod ed_misc_coms.mod ed_para_coms.mod ename_coms.mod fusion_fission_coms.mod grid_coms.mod mem_polygons.mod met_driver_coms.mod pft_coms.mod phenology_coms.mod physiology_coms.mod rk4_coms.mod soil_coms.mod
ed_opspec.mod: ED2/ED/src/io/ed_opspec.o
ED2/ED/src/io/ed_opspec.o: canopy_air_coms.mod canopy_layer_coms.mod canopy_radiation_coms.mod consts_coms.mod decomp_coms.mod detailed_coms.mod disturb_coms.mod ed_max_dims.mod ed_misc_coms.mod ed_para_coms.mod fusion_fission_coms.mod grid_coms.mod mem_polygons.mod met_driver_coms.mod pft_coms.mod phenology_coms.mod physiology_coms.mod rk4_coms.mod soil_coms.mod
ed_print.mod: ED2/ED/src/io/ed_print.o
ED2/ED/src/io/ed_print.o: ed_max_dims.mod ed_misc_coms.mod ed_node_coms.mod ed_state_vars.mod ed_var_tables.mod
ed_read_ed10_20_history.mod: ED2/ED/src/io/ed_read_ed10_20_history.o
ED2/ED/src/io/ed_read_ed10_20_history.o: allometry.mod consts_coms.mod decomp_coms.mod disturb_coms.mod ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod ed_type_init.mod fuse_fiss_utils.mod grid_coms.mod pft_coms.mod physiology_coms.mod update_derived_utils.mod
ed_read_ed21_history.mod: ED2/ED/src/io/ed_read_ed21_history.o
ED2/ED/src/io/ed_read_ed21_history.o: allometry.mod consts_coms.mod decomp_coms.mod disturb_coms.mod ed_init.mod ed_init_history.mod ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod ed_type_init.mod fuse_fiss_utils.mod grid_coms.mod hdf5_coms.mod met_driver_coms.mod pft_coms.mod physiology_coms.mod soil_coms.mod update_derived_utils.mod
ed_xml_config.mod: ED2/ED/src/io/ed_xml_config.o
ED2/ED/src/io/ed_xml_config.o: budget_utils.mod canopy_air_coms.mod canopy_radiation_coms.mod decomp_coms.mod disturb_coms.mod ed_max_dims.mod ed_misc_coms.mod fusion_fission_coms.mod grid_coms.mod hydrology_coms.mod met_driver_coms.mod pft_coms.mod phenology_coms.mod physiology_coms.mod rk4_coms.mod soil_coms.mod
h5_output.mod: ED2/ED/src/io/h5_output.o
ED2/ED/src/io/h5_output.o: ed_max_dims.mod ed_misc_coms.mod ed_node_coms.mod ed_state_vars.mod ed_var_tables.mod fusion_fission_coms.mod grid_coms.mod hdf5_coms.mod
leaf_database.mod: ED2/ED/src/io/leaf_database.o
ED2/ED/src/io/leaf_database.o: grid_coms.mod hdf5_utils.mod soil_coms.mod
c34constants.mod: ED2/ED/src/memory/c34constants.o
canopy_air_coms.mod: ED2/ED/src/memory/canopy_air_coms.o
ED2/ED/src/memory/canopy_air_coms.o: consts_coms.mod therm_lib8.mod
canopy_layer_coms.mod: ED2/ED/src/memory/canopy_layer_coms.o
canopy_radiation_coms.mod: ED2/ED/src/memory/canopy_radiation_coms.o
ED2/ED/src/memory/canopy_radiation_coms.o: ed_max_dims.mod
consts_coms.mod: ED2/ED/src/memory/consts_coms.o
decomp_coms.mod: ED2/ED/src/memory/decomp_coms.o
detailed_coms.mod: ED2/ED/src/memory/detailed_coms.o
disturb_coms.mod: ED2/ED/src/memory/disturb_coms.o
ED2/ED/src/memory/disturb_coms.o: ed_max_dims.mod
ed_max_dims.mod: ED2/ED/src/memory/ed_max_dims.o
ed_mem_alloc.mod: ED2/ED/src/memory/ed_mem_alloc.o
ED2/ED/src/memory/ed_mem_alloc.o: ed_max_dims.mod ed_node_coms.mod ed_state_vars.mod ed_work_vars.mod grid_coms.mod mem_polygons.mod
ed_misc_coms.mod: ED2/ED/src/memory/ed_misc_coms.o
ED2/ED/src/memory/ed_misc_coms.o: ed_max_dims.mod
ed_state_vars.mod: ED2/ED/src/memory/ed_state_vars.o
ED2/ED/src/memory/ed_state_vars.o: disturb_coms.mod ed_max_dims.mod ed_misc_coms.mod ed_node_coms.mod ed_var_tables.mod fusion_fission_coms.mod grid_coms.mod met_driver_coms.mod phenology_coms.mod soil_coms.mod
ed_var_tables.mod: ED2/ED/src/memory/ed_var_tables.o
ED2/ED/src/memory/ed_var_tables.o: ed_max_dims.mod
ed_work_vars.mod: ED2/ED/src/memory/ed_work_vars.o
ED2/ED/src/memory/ed_work_vars.o: ed_max_dims.mod
ename_coms.mod: ED2/ED/src/memory/ename_coms.o
ED2/ED/src/memory/ename_coms.o: ed_max_dims.mod
fusion_fission_coms.mod: ED2/ED/src/memory/fusion_fission_coms.o
ED2/ED/src/memory/fusion_fission_coms.o: ed_max_dims.mod
grid_coms.mod: ED2/ED/src/memory/grid_coms.o
ED2/ED/src/memory/grid_coms.o: ed_max_dims.mod
hdf5_coms.mod: ED2/ED/src/memory/hdf5_coms.o
hydrology_coms.mod: ED2/ED/src/memory/hydrology_coms.o
hydrology_constants.mod: ED2/ED/src/memory/hydrology_constants.o
mem_polygons.mod: ED2/ED/src/memory/mem_polygons.o
ED2/ED/src/memory/mem_polygons.o: ed_max_dims.mod
met_driver_coms.mod: ED2/ED/src/memory/met_driver_coms.o
ED2/ED/src/memory/met_driver_coms.o: ed_max_dims.mod
pft_coms.mod: ED2/ED/src/memory/pft_coms.o
ED2/ED/src/memory/pft_coms.o: ed_max_dims.mod
phenology_coms.mod: ED2/ED/src/memory/phenology_coms.o
ED2/ED/src/memory/phenology_coms.o: ed_max_dims.mod
physiology_coms.mod: ED2/ED/src/memory/physiology_coms.o
ED2/ED/src/memory/physiology_coms.o: ed_max_dims.mod
rk4_coms.mod: ED2/ED/src/memory/rk4_coms.o
ED2/ED/src/memory/rk4_coms.o: ed_max_dims.mod grid_coms.mod
soil_coms.mod: ED2/ED/src/memory/soil_coms.o
ED2/ED/src/memory/soil_coms.o: consts_coms.mod ed_max_dims.mod grid_coms.mod
ed_mpass_init.mod: ED2/ED/src/mpi/ed_mpass_init.o
ED2/ED/src/mpi/ed_mpass_init.o: canopy_air_coms.mod canopy_layer_coms.mod canopy_radiation_coms.mod decomp_coms.mod detailed_coms.mod disturb_coms.mod ed_max_dims.mod ed_mem_alloc.mod ed_misc_coms.mod ed_node_coms.mod ed_para_coms.mod ed_state_vars.mod ed_work_vars.mod fusion_fission_coms.mod grid_coms.mod mem_polygons.mod met_driver_coms.mod pft_coms.mod phenology_coms.mod physiology_coms.mod rk4_coms.mod soil_coms.mod
ed_node_coms.mod: ED2/ED/src/mpi/ed_node_coms.o
ED2/ED/src/mpi/ed_node_coms.o: ed_max_dims.mod
ed_para_coms.mod: ED2/ED/src/mpi/ed_para_coms.o
ED2/ED/src/mpi/ed_para_coms.o: ed_max_dims.mod
ed_para_init.mod: ED2/ED/src/mpi/ed_para_init.o
ED2/ED/src/mpi/ed_para_init.o: ed_init_history.mod ed_max_dims.mod ed_misc_coms.mod ed_node_coms.mod ed_para_coms.mod ed_work_vars.mod grid_coms.mod hdf5_coms.mod mem_polygons.mod soil_coms.mod
allometry.mod: ED2/ED/src/utils/allometry.o
ED2/ED/src/utils/allometry.o: consts_coms.mod ed_misc_coms.mod ed_state_vars.mod grid_coms.mod pft_coms.mod rk4_coms.mod soil_coms.mod therm_lib.mod
budget_utils.mod: ED2/ED/src/utils/budget_utils.o
ED2/ED/src/utils/budget_utils.o: consts_coms.mod ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod grid_coms.mod rk4_coms.mod soil_coms.mod therm_lib.mod
charutils.mod: ED2/ED/src/utils/charutils.o
dateutils.mod: ED2/ED/src/utils/dateutils.o
ED2/ED/src/utils/dateutils.o: consts_coms.mod
ed_cn_utils.mod: ED2/ED/src/utils/ed_cn_utils.o
ED2/ED/src/utils/ed_cn_utils.o: ed_max_dims.mod ed_state_vars.mod pft_coms.mod
ed_filelist.mod: ED2/ED/src/utils/ed_filelist.o
ED2/ED/src/utils/ed_filelist.o: ed_max_dims.mod
ed_grid.mod: ED2/ED/src/utils/ed_grid.o
ED2/ED/src/utils/ed_grid.o: consts_coms.mod ed_max_dims.mod ed_node_coms.mod grid_coms.mod
ed_therm_lib.mod: ED2/ED/src/utils/ed_therm_lib.o
ED2/ED/src/utils/ed_therm_lib.o: canopy_air_coms.mod consts_coms.mod ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod grid_coms.mod pft_coms.mod rk4_coms.mod soil_coms.mod therm_lib.mod therm_lib8.mod
fatal_error.mod: ED2/ED/src/utils/fatal_error.o
ED2/ED/src/utils/fatal_error.o: ed_node_coms.mod
fuse_fiss_utils.mod: ED2/ED/src/utils/fuse_fiss_utils.o
ED2/ED/src/utils/fuse_fiss_utils.o: allometry.mod budget_utils.mod consts_coms.mod disturb_coms.mod ed_max_dims.mod ed_misc_coms.mod ed_node_coms.mod ed_state_vars.mod ed_therm_lib.mod ed_type_init.mod fusion_fission_coms.mod grid_coms.mod mem_polygons.mod met_driver_coms.mod pft_coms.mod plant_hydro.mod rk4_coms.mod soil_coms.mod stable_cohorts.mod therm_lib.mod update_derived_utils.mod
great_circle.mod: ED2/ED/src/utils/great_circle.o
ED2/ED/src/utils/great_circle.o: consts_coms.mod
hdf5_utils.mod: ED2/ED/src/utils/hdf5_utils.o
ED2/ED/src/utils/hdf5_utils.o: hdf5_coms.mod
hrzshade_utils.mod: ED2/ED/src/utils/hrzshade_utils.o
ED2/ED/src/utils/hrzshade_utils.o: allometry.mod canopy_radiation_coms.mod consts_coms.mod disturb_coms.mod ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod pft_coms.mod random_utils.mod rk4_coms.mod
invmondays.mod: ED2/ED/src/utils/invmondays.o
ED2/ED/src/utils/invmondays.o: ed_misc_coms.mod
lapse.mod: ED2/ED/src/utils/lapse.o
ED2/ED/src/utils/lapse.o: consts_coms.mod ed_misc_coms.mod ed_state_vars.mod met_driver_coms.mod
libxml2f90.f90_pp.mod: ED2/ED/src/utils/libxml2f90.f90_pp.o
numutils.mod: ED2/ED/src/utils/numutils.o
ED2/ED/src/utils/numutils.o: consts_coms.mod
radiate_utils.mod: ED2/ED/src/utils/radiate_utils.o
ED2/ED/src/utils/radiate_utils.o: canopy_radiation_coms.mod consts_coms.mod ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod met_driver_coms.mod update_derived_utils.mod
random_utils.mod: ED2/ED/src/utils/random_utils.o
rsys.mod: ED2/ED/src/utils/rsys.o
stable_cohorts.mod: ED2/ED/src/utils/stable_cohorts.o
ED2/ED/src/utils/stable_cohorts.o: allometry.mod ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod ed_therm_lib.mod pft_coms.mod physiology_coms.mod plant_hydro.mod
therm_lib.mod: ED2/ED/src/utils/therm_lib.o
ED2/ED/src/utils/therm_lib.o: consts_coms.mod
therm_lib8.mod: ED2/ED/src/utils/therm_lib8.o
ED2/ED/src/utils/therm_lib8.o: consts_coms.mod therm_lib.mod
update_derived_utils.mod: ED2/ED/src/utils/update_derived_utils.o
ED2/ED/src/utils/update_derived_utils.o: allometry.mod canopy_air_coms.mod canopy_radiation_coms.mod consts_coms.mod detailed_coms.mod ed_max_dims.mod ed_misc_coms.mod ed_state_vars.mod ed_therm_lib.mod fusion_fission_coms.mod grid_coms.mod pft_coms.mod phenology_coms.mod physiology_coms.mod soil_coms.mod therm_lib.mod
utils_f.mod: ED2/ED/src/utils/utils_f.o
