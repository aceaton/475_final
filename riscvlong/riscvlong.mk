#=========================================================================
# riscvlong Subpackage
#=========================================================================

riscvlong_deps = \
  vc \
  imuldiv \

riscvlong_srcs = \
  riscvlong-CoreDpath.v \
  riscvlong-CoreDpathRegfile.v \
  riscvlong-CoreDpathAlu.v \
  riscvlong-CoreCtrl.v \
  riscvlong-Core.v \
  riscvlong-InstMsg.v \
  riscvlong-CoreDpathPipeMulDiv.v \

riscvlong_test_srcs = \
  riscvlong-InstMsg.t.v \
  riscvlong-CoreDpathPipeMulDiv.t.v \

riscvlong_prog_srcs = \
  riscvlong-sim.v \
  riscvlong-randdelay-sim.v \

