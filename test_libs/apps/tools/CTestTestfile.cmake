# CMake generated Testfile for 
# Source directory: /home/sik/code/openmeeg/apps/tools
# Build directory: /home/sik/Workspace/openmeeg/test_libs/apps/tools
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(wrong_geom_info "/home/sik/Workspace/openmeeg/test_libs/apps/tools/om_geometry_info" "-g" "/home/sik/code/openmeeg/data/HeadNNc1/HeadNNc1.geom" "-c" "/home/sik/code/openmeeg/data/Head1/Head1.cond")
set_tests_properties(wrong_geom_info PROPERTIES  WILL_FAIL "TRUE")
