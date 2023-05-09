#=========================================================================
# Makefile for Verilog Packages
#=========================================================================
# This is a simple start to a much more sophisticated Verilog build
# system. For most packages, a developer will not need to make any
# changes to this file except to make sure that the subpkgs make variable
# correctly lists the desired subpackages to include in this package.
# Developers also need to make sure each subpackage makefile fragment
# (e.g., vc.mk) is uptodate with a list of all of the subpackage
# dependencies, Verilog source files, test source files, and program
# source files. The key targets for this Makefile are as follows:
#
#  - default   : build all programs
#  - check     : build and run all unit tests
#  - clean     : remove all generated content
#

#-------------------------------------------------------------------------
# Basic setup
#-------------------------------------------------------------------------

# Remove all default implicit rules since they can cause subtle bugs
# and they just make things run slower
.SUFFIXES:
% : %,v
% : RCS/%,v
% : RCS/%
% : s.%
% : SCCS/s.%

# Default is to build the prereqs of the all target (defined at bottom)
default : all
.PHONY : default

topdir = ..

#-------------------------------------------------------------------------
# List of subpackages
#-------------------------------------------------------------------------

subpkgs = \
  vc \
  imuldiv \
  mcriscv \
  riscvstall \
  riscvbyp \
  riscvlong \
  riscvdualfetch \
  riscvssc \

#-------------------------------------------------------------------------
# List of Assembly Tests
#-------------------------------------------------------------------------

tests = \
  riscv-add.vmh \
  riscv-addi.vmh \
  riscv-lui.vmh \
  riscv-ori.vmh \
  riscv-and.vmh \
  riscv-andi.vmh \
  riscv-or.vmh \
  riscv-sll.vmh \
  riscv-slli.vmh \
  riscv-slt.vmh \
  riscv-slti.vmh \
  riscv-sltiu.vmh \
  riscv-sltu.vmh \
  riscv-sra.vmh \
  riscv-srai.vmh \
  riscv-srl.vmh \
  riscv-srli.vmh \
  riscv-sub.vmh \
  riscv-xor.vmh \
  riscv-xori.vmh \
  riscv-bne.vmh \
  riscv-blt.vmh \
  riscv-jal.vmh \
  riscv-lw.vmh \
  riscv-sw.vmh \
  riscv-jr.vmh \
  riscv-beq.vmh \
  riscv-bge.vmh \
  riscv-bgeu.vmh \
  riscv-bltu.vmh \
  riscv-div.vmh \
  riscv-divu.vmh \
  riscv-j.vmh \
  riscv-jalr.vmh \
  riscv-lb.vmh \
  riscv-lbu.vmh \
  riscv-lh.vmh \
  riscv-lhu.vmh \
  riscv-mul.vmh \
  riscv-rem.vmh \
  riscv-remu.vmh \
  riscv-sb.vmh \
  riscv-sh.vmh \
  ubmark-vvadd.vmh \
  ubmark-vvadd1.vmh \

riscvstall_rtl_sim = riscvstall-sim
riscvstall_rtl_rand_sim = riscvstall-randdelay-sim
riscvbyp_rtl_sim = riscvbyp-sim
riscvbyp_rtl_rand_sim = riscvbyp-randdelay-sim
riscvlong_rtl_sim = riscvlong-sim
riscvlong_rtl_rand_sim = riscvlong-randdelay-sim
riscvdualfetch_rtl_sim = riscvdualfetch-sim
riscvdualfetch_rtl_rand_sim = riscvdualfetch-randdelay-sim
riscvssc_rtl_sim = riscvssc-sim
riscvssc_rtl_rand_sim = riscvssc-randdelay-sim

stall_tests_outs = $(patsubst %.vmh,%-stall.out,$(tests))
$(stall_tests_outs) : %-stall.out : %.vmh $(riscvstall_rtl_sim)
	./$(riscvstall_rtl_sim) +stats=1 +vcd=1 +exe=$< > $@

stall_tests_rand_outs = $(patsubst %.vmh,%-stall-rand.out,$(tests))
$(stall_tests_rand_outs) : %-stall-rand.out : %.vmh $(riscvstall_rtl_rand_sim)
	./$(riscvstall_rtl_rand_sim) +stats=1 +vcd=1 +exe=$< > $@

byp_tests_outs = $(patsubst %.vmh,%-byp.out,$(tests))
$(byp_tests_outs) : %-byp.out : %.vmh $(riscvbyp_rtl_sim)
	./$(riscvbyp_rtl_sim) +stats=1 +vcd=1 +exe=$< > $@

byp_tests_rand_outs = $(patsubst %.vmh,%-byp-rand.out,$(tests))
$(byp_tests_rand_outs) : %-byp-rand.out : %.vmh $(riscvbyp_rtl_rand_sim)
	./$(riscvbyp_rtl_rand_sim) +stats=1 +vcd=1 +exe=$< > $@

long_tests_outs = $(patsubst %.vmh,%-long.out,$(tests))
$(long_tests_outs) : %-long.out : %.vmh $(riscvlong_rtl_sim)
	./$(riscvlong_rtl_sim) +stats=1 +vcd=1 +exe=$< > $@

long_tests_rand_outs = $(patsubst %.vmh,%-long-rand.out,$(tests))
$(long_tests_rand_outs) : %-long-rand.out : %.vmh $(riscvlong_rtl_rand_sim)
	./$(riscvlong_rtl_rand_sim) +stats=1 +vcd=1 +exe=$< > $@


dualfetch_tests_outs = $(patsubst %.vmh,%-dualfetch.out,$(tests))
$(dualfetch_tests_outs) : %-dualfetch.out : %.vmh $(riscvdualfetch_rtl_sim)
	./$(riscvdualfetch_rtl_sim) +stats=1 +vcd=1 +exe=$< > $@

dualfetch_tests_rand_outs = $(patsubst %.vmh,%-dualfetch-rand.out,$(tests))
$(dualfetch_tests_rand_outs) : %-dualfetch-rand.out : %.vmh $(riscvdualfetch_rtl_rand_sim)
	./$(riscvdualfetch_rtl_rand_sim) +stats=1 +vcd=1 +exe=$< > $@

ssc_tests_outs = $(patsubst %.vmh,%-ssc.out,$(tests))
$(ssc_tests_outs) : %-ssc.out : %.vmh $(riscvssc_rtl_sim)
	./$(riscvssc_rtl_sim) +stats=1 +vcd=1 +exe=$< > $@

ssc_tests_rand_outs = $(patsubst %.vmh,%-ssc-rand.out,$(tests))
$(ssc_tests_rand_outs) : %-ssc-rand.out : %.vmh $(riscvssc_rtl_rand_sim)
	./$(riscvssc_rtl_rand_sim) +stats=1 +vcd=1 +exe=$< > $@

check-asm-riscvstall : $(stall_tests_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(stall_tests_outs); echo;

check-asm-rand-riscvstall : $(stall_tests_rand_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(stall_tests_rand_outs); echo;

check-asm-riscvbyp : $(byp_tests_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(byp_tests_outs); echo;

check-asm-rand-riscvbyp : $(byp_tests_rand_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(byp_tests_rand_outs); echo;

check-asm-riscvlong : $(long_tests_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(long_tests_outs); echo;

check-asm-rand-riscvlong : $(long_tests_rand_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(long_tests_rand_outs); echo;

check-asm-riscvdualfetch : $(dualfetch_tests_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(dualfetch_tests_outs); echo;

check-asm-rand-riscvdualfetch : $(dualfetch_tests_rand_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(dualfetch_tests_rand_outs); echo;

check-asm-riscvssc : $(ssc_tests_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(ssc_tests_outs); echo;

check-asm-rand-riscvssc : $(ssc_tests_rand_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(ssc_tests_rand_outs); echo;

junk += $(stall_tests_outs)
junk += $(stall_tests_rand_outs)
junk += $(byp_tests_outs)
junk += $(byp_tests_rand_outs)
junk += $(long_tests_outs)
junk += $(long_tests_rand_outs)
junk += $(dualfetch_tests_outs)
junk += $(dualfetch_tests_rand_outs)
junk += $(ssc_tests_outs)
junk += $(ssc_tests_rand_outs)

#-------------------------------------------------------------------------
# List of Benchmarks
#-------------------------------------------------------------------------

bmarks = \
  ubmark-vvadd.vmh \
  ubmark-cmplx-mult.vmh \
  ubmark-masked-filter.vmh \
  ubmark-bin-search.vmh \

stall_bmarks_outs = $(patsubst %.vmh,%-stall.out,$(bmarks))
$(stall_bmarks_outs) : %-stall.out : %.vmh $(riscvstall_rtl_sim)
	./$(riscvstall_rtl_sim) +verbose=1 +vcd=1 +exe=$< > $@

byp_bmarks_outs = $(patsubst %.vmh,%-byp.out,$(bmarks))
$(byp_bmarks_outs) : %-byp.out : %.vmh $(riscvbyp_rtl_sim)
	./$(riscvbyp_rtl_sim) +verbose=1 +vcd=1 +exe=$< > $@

long_bmarks_outs = $(patsubst %.vmh,%-long.out,$(bmarks))
$(long_bmarks_outs) : %-long.out : %.vmh $(riscvlong_rtl_sim)
	./$(riscvlong_rtl_sim) +verbose=1 +vcd=1 +exe=$< > $@

dualfetch_bmarks_outs = $(patsubst %.vmh,%-dualfetch.out,$(bmarks))
$(dualfetch_bmarks_outs) : %-dualfetch.out : %.vmh $(riscvdualfetch_rtl_sim)
	./$(riscvdualfetch_rtl_sim) +verbose=1 +vcd=1 +exe=$< > $@

ssc_bmarks_outs = $(patsubst %.vmh,%-ssc.out,$(bmarks))
$(ssc_bmarks_outs) : %-ssc.out : %.vmh $(riscvssc_rtl_sim)
	./$(riscvssc_rtl_sim) +verbose=1 +vcd=1 +exe=$< > $@

run-bmark-riscvstall : $(stall_bmarks_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(stall_bmarks_outs); echo;

run-bmark-riscvbyp : $(byp_bmarks_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(byp_bmarks_outs); echo;

run-bmark-riscvlong : $(long_bmarks_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(long_bmarks_outs); echo;

run-bmark-riscvdualfetch : $(dualfetch_bmarks_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(dualfetch_bmarks_outs); echo;

run-bmark-riscvssc : $(ssc_bmarks_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(ssc_bmarks_outs); echo;

stall_bmarks_rand_outs = $(patsubst %.vmh,%-stall-rand.out,$(bmarks))
byp_bmarks_rand_outs = $(patsubst %.vmh,%-byp-rand.out,$(bmarks))
long_bmarks_rand_outs = $(patsubst %.vmh,%-long-rand.out,$(bmarks))
dualfetch_bmarks_rand_outs = $(patsubst %.vmh,%-dualfetch-rand.out,$(bmarks))
ssc_bmarks_rand_outs = $(patsubst %.vmh,%-ssc-rand.out,$(bmarks))

$(stall_bmarks_rand_outs) : %-stall-rand.out : %.vmh $(riscvstall_rtl_rand_sim)
	./$(riscvstall_rtl_rand_sim) +verbose=1 +vcd=1 +exe=$< > $@

$(byp_bmarks_rand_outs) : %-byp-rand.out : %.vmh $(riscvbyp_rtl_rand_sim)
	./$(riscvbyp_rtl_rand_sim) +verbose=1 +vcd=1 +exe=$< > $@

$(long_bmarks_rand_outs) : %-long-rand.out : %.vmh $(riscvlong_rtl_rand_sim)
	./$(riscvlong_rtl_rand_sim) +verbose=1 +vcd=1 +exe=$< > $@

$(dualfetch_bmarks_rand_outs) : %-dualfetch-rand.out : %.vmh $(riscvdualfetch_rtl_rand_sim)
	./$(riscvdualfetch_rtl_rand_sim) +verbose=1 +vcd=1 +exe=$< > $@

$(ssc_bmarks_rand_outs) : %-ssc-rand.out : %.vmh $(riscvssc_rtl_rand_sim)
	./$(riscvssc_rtl_rand_sim) +verbose=1 +vcd=1 +exe=$< > $@

run-bmark-rand-riscvstall : $(stall_bmarks_rand_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(stall_bmarks_rand_outs); echo;

run-bmark-rand-riscvbyp : $(byp_bmarks_rand_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(byp_bmarks_rand_outs); echo;

run-bmark-rand-riscvlong : $(long_bmarks_rand_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(long_bmarks_rand_outs); echo;

run-bmark-rand-riscvdualfetch : $(dualfetch_bmarks_rand_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(dualfetch_bmarks_rand_outs); echo;

run-bmark-rand-riscvssc : $(ssc_bmarks_rand_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(ssc_bmarks_rand_outs); echo;

junk += $(stall_bmarks_outs)
junk += $(byp_bmarks_outs)
junk += $(dualfetch_bmarks_outs)
junk += $(ssc_bmarks_outs)
junk += $(long_bmarks_outs)

#-------------------------------------------------------------------------
# Programs
#-------------------------------------------------------------------------

COMP       = iverilog
COMP_FLAGS = -g2005 -Wall -Wno-sensitivity-entire-vector -Wno-sensitivity-entire-array

#-------------------------------------------------------------------------
# Makefile fragments from subpackages
#-------------------------------------------------------------------------

subpkgs_mk := \
  $(join $(addprefix $(topdir)/, $(subpkgs)), \
         $(patsubst %, /%.mk, $(subpkgs)))

-include $(subpkgs_mk)
VPATH := $(addprefix $(topdir)/, $(subpkgs))

VPATH += $(topdir)/tests/build/vmh
VPATH += $(topdir)/ubmark/build/vmh

#-------------------------------------------------------------------------
# Template for per subpackage rules
#-------------------------------------------------------------------------

# Helper template for collecting sources from subpackage dependencies

define subpkg_template_collect_deps
$(1)_deps_srcs += $$($(2)_srcs)
endef

# Main subpackage template

define subpkg_template

# Subpackage subdirectory

$(2)_dir := $$(addprefix $(topdir)/, $(1))

# Subpackage dependencies

$(2)_incs := $$(addprefix -I $(topdir)/, $$($(2)_deps))

$$(foreach dep,$$($(2)_deps), \
  $$(eval $$(call subpkg_template_collect_deps,$(2),$$(dep))))

# Build unit tests

$(2)_test_exes := $$(patsubst %.t.v,%-utst,$$($(2)_test_srcs))

$$($(2)_test_exes) : %-utst : $$($(2)_dir)/%.t.v $$($(2)_srcs) $$($(2)_deps_srcs)
	$(COMP) $(COMP_FLAGS) -o $$@ \
    -I $(topdir)/vc -I $(topdir)/$(2) $$($(2)_incs) $$<

$(2)_junk += $$($(2)_test_exes)

# Run unit tests

$(2)_test_outs := $$(addsuffix .out, $$($(2)_test_exes))

$$($(2)_test_outs) : %.out : %
	./$$< +verbose=2 > $$@

$(2)_junk += $$($(2)_test_outs)

# Build programs

$(2)_prog_exes := $$(patsubst %.v, %, $$($(2)_prog_srcs))

$$($(2)_prog_exes) : % : $$($(2)_dir)/%.v $$($(2)_srcs) $$($(2)_deps_srcs)
	$(COMP) $(COMP_FLAGS) -o $$@ \
    -I $(topdir)/$(2) $$($(2)_incs) $$<

$(2)_junk += $$($(2)_prog_exes)

# Other subpkg specific targets

all-$(1) : $$($(2)_prog_exes)

check-$(1) : $$($(2)_test_outs)
	@echo
	@grep -h -e "Entering Test Suite" -e "FAILED" $($(2)_test_outs)
	@echo;

clean-$(1) :
	rm -rf $$($(2)_junk)

.PHONY : all-$(1) check-$(1) clean-$(1)

# Update running variables

exes += $$($(2)_prog_exes)
outs += $$($(2)_test_outs)
junk += $$($(2)_junk)

endef

# Call template for each subpackage

$(foreach subpkg,$(subpkgs), \
  $(eval $(call subpkg_template,$(subpkg),$(subst -,_,$(subpkg)))))

#-------------------------------------------------------------------------
# Check
#-------------------------------------------------------------------------

check : $(outs)
	@echo
	@grep -h -e "Entering Test Suite" -e "FAILED" $(outs)
	@echo;

.PHONY : check

#-------------------------------------------------------------------------
# Default
#-------------------------------------------------------------------------

all : $(exes)
.PHONY : all

#-------------------------------------------------------------------------
# Makefile debugging
#-------------------------------------------------------------------------
# This handy rule will display the contents of any make variable by
# using the target debug-<varname>. So for example, make debug-junk will
# display the contents of the junk variable.

debug-% :
	@echo $* = $($*)

#-------------------------------------------------------------------------
# Clean up junk
#-------------------------------------------------------------------------

clean :
	rm -rf *~ \#* *.vcd $(junk)

.PHONY : clean

