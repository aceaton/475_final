#=========================================================================
# imuldiv Subpackage
#=========================================================================

imuldiv_deps = vc

imuldiv_srcs = \
  imuldiv-DivReqMsg.v \
  imuldiv-MulDivReqMsg.v \
  imuldiv-IntMulIterative.v \
  imuldiv-IntDivIterative.v \
  imuldiv-IntMulDivIterative.v \
  imuldiv-IntMulDivIterativeCombined.v \

imuldiv_test_srcs = \
  imuldiv-DivReqMsg.t.v \
  imuldiv-MulDivReqMsg.t.v \
  imuldiv-IntMulIterative.t.v \
  imuldiv-IntDivIterative.t.v \
  imuldiv-IntMulDivIterative.t.v \
  imuldiv-IntMulDivIterativeCombined.t.v \

imuldiv_prog_srcs = \
  imuldiv-iterative-sim.v \

