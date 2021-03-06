#
# Modified by Fernando Lorenzo on 9-25-2010 to use Lapack Solver
# Modified by Fernando Lorenzo on  April 1st 2011 to add Von Mises Stresses

#***********  fortran 2 c *******************
# Set F2C (for unix -lf2c and for MS windows if using Visual C++ to f2c.lib)

F2C= -lf2c 
#  ***********  hypoplasticity ****************
# For hypoplasticity:
#    install f2c on your computer (also see F2C above)
#    set HYPO_USE to 1 in tnhypo.h
#    set HYPO_SRC to hypo.c below
#    set HYPO_OBJ to hypo.o below
HYPO_SRC=hypo.c
HYPO_OBJ=hypo.o

#  ***********  profiler ***********************
# for the gnu profiler, use as follows:
# set PROFILE to -pg
# compile and link
# tochnog
# gprof tochnog > gprof.sum
# vi gprof.sum
#PROFILE= #-pg

#  ***********  default environment *******************
SRC_CPP=cc
SRC_C=c
SYS_FILE=sysother
BCPP=-P
VCPP=
COMPILER_C=bcc32
COMPILER_CPP=bcc32
COMPILER_FLAGS= -c -O2 -w-
OBJ=obj
LINK_FLAGS_BEFORE= -l$(F2C)
LINK_FLAGS_AFTER=

#  ***********  SUPERLU library *******************
# For SUPERLU usage:
#   1. Set SUPERLU_USE to 1 in tnsuplu.h for the sequential version
#      Set SUPERLU_MT_USE to 1 in tnsuplu.h for the multi threaded version
#      Set SUPERLU_DIST_USE to 1 in tnsuplu.h for the distributed MPI version
#   2. Activate and adjust the next three lines
#      SUPERLU= $(HOME)/Tochnog/SuperLU_4.3
#      SUPERLU_LIB= /Users/fdolorenzo/Downloads/petsc-3.4.2/arch-darwin-c-debug/lib/
#      libsuperlu_dist_3.3.a	
#      SUPERLU_INCLUDE=-I/Users/fdolorenzo/Downloads/petsc-3.4.2/arch-darwin-c-debug/include
#      3. For SuperLU_MT be sure to compile a multi threaded version
#      of Tochnog (sparc_parallel, alpha_parallel, linux, etc.

#  ***********  PetSc library *******************
# Do NOT link together with the SUPERLU library
# For PetSc usage:
#   1. Activate special lines for petsc version 2.2.29 and further in so_petsc.c
#   2. Set PETSC_DIR in your environment
#   3. Set PETSC_USE to 1 in tnpetsc.h
#   4. Activate the lines with PETSC_INCLUDE and PETSC_LIB
# For PetSc + MPI usage also:
#   5. Set MPI_USE to 1 in tnpetsc.h for distributed computing with MPI
#   6. Replace $(PETSC_DIR)/src/sys/src/mpiuni with $(MPI_HOME)/include (or so)
#   7. Replace -lmpiuni with -lmpich (or so) 
#   8. Take care that PETSC_DIR and PETSC_ARCH are set in your environment
#PETSC_INCLUDE=
#PETSC_LIB= -L/usr/local/lib -lpetsc -lmpi 
# Activate the two lines below to use the LAPACK Solver.

# For other systems the blas library is at /usr/lib/-lblas or /usr/local/lib/-lblas, and 
# the lapack library normally installs at  /usr/lib/-llapack or /usr/local/lib/-liblapack
# For OSX use both BLAS_LIB and LAPACK_LIB equal to -framework Accelerate
				
BLAS_LIB= 
LAPACK_LIB= 

#
#  ***********  All libraries *******************

ALL_INCLUDE= $(PETSC_INCLUDE) $(SUPERLU_INCLUDE) $(LAPACK_INCLUDE)
ALL_LIB=  $(LAPACK_LIB)  $(BLAS_LIB) $(F2C) -lm $(PETSC_LIB) $(SUPERLU_LIB)

#  ***********  default platform  *******************
default: darwin-intel

# single and multi-processor windows; borland c++ compiler
# set SYS_FILE above to syswin32 for multi-processor
borland_cpp:
	make tochnog
	del tochnog.exe > nul
	ren adjust.exe tochnog.exe

# single processor windows; visual c++ compiler
visual_cpp:
	nmake tochnog \
	"SYS_FILE=sysother" \
	"OBJ=obj" \
	"BCPP=" \
	"VCPP=/Tp" \
	"COMPILER_C=cl" \
	"COMPILER_CPP=cl" \
	"COMPILER_FLAGS= /c /O2 $(PROFILE)" \
	"LINK_FLAGS_BEFORE=" \
	"LINK_FLAGS_AFTER= /link $(F2C) $(PROFILE) /OUT:tochnog.exe"

# multi processor windows; visual c++ compiler
visual_cpp_parallel:
	nmake tochnog \
	"SYS_FILE=syswin32" \
	"OBJ=obj" \
	"BCPP=" \
	"VCPP=/Tp" \
	"COMPILER_C=cl" \
	"COMPILER_CPP=cl" \
	"COMPILER_FLAGS= /MT /c /O2 $(PROFILE)" \
	"LINK_FLAGS_BEFORE=" \
	"LINK_FLAGS_AFTER= /link $(F2C) $(PROFILE) /OUT:tochnog.exe"

# Mac OSX; gnu gcc compiler -undefined dynamic_lookup
# Use this option to build tochnog with code optimized for darwin-intel64bit:
darwin-intel: 
	make tochnog \
	"SYS_FILE=sysother" \
	"OBJ=o" \
	"BCPP=" \
	"VCPP=" \
	"COMPILER_C=gcc" \
	"COMPILER_CPP=g++" \
	"COMPILER_FLAGS= -O3 -g -Wconversion -Wformat  -ansi -c -Wall $(ALL_INCLUDE) $(PROFILE) " \
	"LINK_FLAGS_BEFORE= -v  " \
	"LINK_FLAGS_AFTER=-g -v -dynamic -undefined dynamic_lookup  $(ALL_LIB) $(PROFILE) -dynamic -lpthread -o tochnog"

# single processor linux; gnu gcc compiler
linux_old: 
	make tochnog \
	"SYS_FILE=sysother" \
	"OBJ=o" \
	"BCPP=" \
	"VCPP=" \
	"COMPILER_C=gcc" \
	"COMPILER_CPP=g++-4.2" \
	"COMPILER_FLAGS= -ansi -c -O2 -Wall $(PROFILE) $(ALL_INCLUDE)" \
	"LINK_FLAGS_BEFORE=" \
	"LINK_FLAGS_AFTER= $(PROFILE) $(ALL_LIB) -static -lm -o tochnog"

# multi processor linux; gnu gcc compiler
linux: 
	make tochnog \
	"SYS_FILE=sysposix" \
	"OBJ=o" \
	"BCPP=" \
	"VCPP=" \
	"COMPILER_C=gcc" \
	"COMPILER_CPP=g++" \
	"COMPILER_FLAGS= -ansi -c -O2 -m486 -Wall -D_REENTRANT $(PROFILE) $(ALL_INCLUDE)" \
	"LINK_FLAGS_BEFORE=" \
	"LINK_FLAGS_AFTER= $(PROFILE) $(ALL_LIB) -static -lm -lpthread -o tochnog"

# insure check under linux; insure + gnu gcc compiler
# set   insure++.compiler g++   in the file .psrc in your home directory
linux_insure: 
	make tochnog \
	"SYS_FILE=sysother" \
	"OBJ=o" \
	"BCPP=" \
	"VCPP=" \
	"COMPILER_C=gcc" \
	"COMPILER_CPP=insure" \
	"COMPILER_FLAGS= -ansi -g -c -Wall $(PROFILE) $(ALL_INCLUDE)" \
	"LINK_FLAGS_BEFORE=" \
	"LINK_FLAGS_AFTER= $(PROFILE) $(ALL_LIB) -static -lm -o tochnog"

# single processor hp unix; hp CC compiler
hp: 
	make tochnog \
	"SYS_FILE=sysother" \
	"OBJ=o" \
	"BCPP=" \
	"VCPP=" \
	"COMPILER_FLAGS= -c -Aa -O $(PROFILE) $(ALL_INCLUDE)" \
	"COMPILER_C=cc" \
	"COMPILER_CPP=CC" \
	"LINK_FLAGS_BEFORE=" \
	"LINK_FLAGS_AFTER= $(PROFILE) $(ALL_LIB) -lm -o tochnog"

# single and multi processor sgi unix; sgi CC compiler
sgi:
	make tochnog \
	"SYS_FILE=syssgi" \
	"OBJ=o" \
	"BCPP=" \
	"VCPP=" \
	"COMPILER_FLAGS= -c -O2 $(PROFILE) $(ALL_INCLUDE)" \
	"COMPILER_C=cc" \
	"COMPILER_CPP=CC" \
	"LINK_FLAGS_BEFORE=" \
	"LINK_FLAGS_AFTER= $(PROFILE)  $(ALL_LIB) -lm -lmpc -o tochnog"

# single processor sun solaris unix; sun CC compiler
sparc:
	make tochnog \
	"SYS_FILE=sysother" \
	"OBJ=o" \
	"BCPP=" \
	"VCPP=" \
	"COMPILER_FLAGS= -w -fast -c $(PROFILE)  $(ALL_INCLUDE)" \
	"COMPILER_C=cc" \
	"COMPILER_CPP=CC" \
	"LINK_FLAGS_BEFORE=" \
	"LINK_FLAGS_AFTER= $(PROFILE) $(ALL_LIB) -lm -o tochnog"

# multi processor sun solaris unix; sun CC compiler
sparc_parallel:
	make tochnog \
	"SYS_FILE=sysposix" \
	"OBJ=o" \
	"BCPP=" \
	"VCPP=" \
	"COMPILER_FLAGS= -w -mt -fast -c $(PROFILE)  $(ALL_INCLUDE)" \
	"COMPILER_C=cc" \
	"COMPILER_CPP=CC" \
	"LINK_FLAGS_BEFORE=-lpthread" \
	"LINK_FLAGS_AFTER= $(PROFILE) $(ALL_LIB) -lm -o tochnog"

# single processor alpha
alpha:
	make tochnog \
	"SYS_FILE=sysother" \
	"OBJ=o" \
	"BCPP=" \
	"VCPP=" \
	"COMPILER_FLAGS= -O2 -c $(PROFILE) $(ALL_INCLUDE)" \
	"COMPILER_C=cc" \
	"COMPILER_CPP=cxx" \
	"LINK_FLAGS_BEFORE=" \
	"LINK_FLAGS_AFTER= $(PROFILE) $(ALL_LIB) -lm -o tochnog"

# multi processor alpha
alpha_parallel:
	make tochnog \
	"SYS_FILE=sysposix" \
	"OBJ=o" \
	"BCPP=" \
	"VCPP=" \
	"COMPILER_FLAGS= -O2 -pthread -D_REENTRANT -c $(PROFILE) $(ALL_INCLUDE)" \
	"COMPILER_C=cc" \
	"COMPILER_CPP=cxx" \
	"LINK_FLAGS_BEFORE=-lpthread -lexc" \
	"LINK_FLAGS_AFTER= $(PROFILE) $(ALL_LIB) -lm -o tochnog"

# NOTICE THAT SINCE WE ARE USING THE LAPACK LIBRARY BUILT WITH YOUR SYSTEM, WE DO NOT 
# BUILD THE clapack.c � However, you need to have it to do eigenvalues or if you want 
# a fast solver. Most Linux applications allow you to install Lapack and Blas 

# In lines below I removed ---clapack.$(OBJ) 

tochnog: adjust.$(OBJ) area.$(OBJ) \
	beam.$(OBJ) bounda.$(OBJ) calcul.$(OBJ) \
	change.$(OBJ) check.$(OBJ) \
	condif.$(OBJ) \
	contact.$(OBJ) conspr.$(OBJ) \
	crack.$(OBJ) create.$(OBJ) \
	damage.$(OBJ) data.$(OBJ) date.$(OBJ) \
	database.$(OBJ) delete.$(OBJ) distri.$(OBJ) \
	dof.$(OBJ) elasti.$(OBJ) elem.$(OBJ) \
	error.$(OBJ) extrude.$(OBJ) failure.$(OBJ) \
	filter.$(OBJ) force.$(OBJ) general.$(OBJ) \
	geometry.$(OBJ) generate.$(OBJ) \
	groundda.$(OBJ) groundfl.$(OBJ) group.$(OBJ) \
        hyperela.$(OBJ) $(HYPO_OBJ) \
	hypoplas.$(OBJ) initia.$(OBJ) \
	input.$(OBJ) integra.$(OBJ) intersec.$(OBJ) \
	inverse.$(OBJ) locate.$(OBJ) \
	macro.$(OBJ) map.$(OBJ) mat_diff.$(OBJ) \
	materi.$(OBJ) math.$(OBJ) maxwell.$(OBJ) \
	membrane.$(OBJ) merge.$(OBJ) mesh.$(OBJ) \
	miscel.$(OBJ) new_mesh.$(OBJ) \
	node.$(OBJ) nonloc.$(OBJ) order.$(OBJ) \
	plasti.$(OBJ) plasti_i.$(OBJ)  \
	point_el.$(OBJ) \
	polynom.$(OBJ) post.$(OBJ) \
	pri.$(OBJ) print_db.$(OBJ) \
	print_da.$(OBJ) print_dx.$(OBJ) print_el.$(OBJ) \
	print_gi.$(OBJ) print_g5.$(OBJ) print_g6.$(OBJ)\
	print_gm.$(OBJ) print_hi.$(OBJ) \
	print_pl.$(OBJ) print_ma.$(OBJ) print_rs.$(OBJ) \
	print_te.$(OBJ) print_un.$(OBJ) print_vt.$(OBJ) \
	project.$(OBJ) range.$(OBJ) \
	refine_g.$(OBJ) refine_l.$(OBJ) remesh.$(OBJ) \
	renumber.$(OBJ) repeat.$(OBJ) restart.$(OBJ) \
	slide.$(OBJ) \
	so.$(OBJ) so_bicg.$(OBJ) \
	   split.$(OBJ) \
	spring.$(OBJ) stress.$(OBJ) \
	$(SYS_FILE).$(OBJ) tendon.$(OBJ) time.$(OBJ) tn.$(OBJ) \
	top.$(OBJ) truss.$(OBJ) \
	umat.$(OBJ) unknown.$(OBJ) user.$(OBJ) \
	viscoela.$(OBJ) viscosit.$(OBJ) visconon.$(OBJ) \
	volume.$(OBJ) wave.$(OBJ)
	$(COMPILER_CPP) $(LINK_FLAGS_BEFORE) *.$(OBJ) $(LINK_FLAGS_AFTER)

adjust.$(OBJ): adjust.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)adjust.$(SRC_CPP)

area.$(OBJ): area.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)area.$(SRC_CPP)

beam.$(OBJ): beam.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)beam.$(SRC_CPP)

bounda.$(OBJ): bounda.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)bounda.$(SRC_CPP)

calcul.$(OBJ): calcul.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)calcul.$(SRC_CPP)

change.$(OBJ): change.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)change.$(SRC_CPP)

check.$(OBJ): check.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)check.$(SRC_CPP)

#clapack.$(OBJ): clapack.c
#	$(COMPILER_C) $(COMPILER_FLAGS) clapack.c

condif.$(OBJ): condif.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)condif.$(SRC_CPP)

contact.$(OBJ): contact.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)contact.$(SRC_CPP)

conspr.$(OBJ): conspr.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)conspr.$(SRC_CPP)

crack.$(OBJ): crack.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)crack.$(SRC_CPP)

create.$(OBJ): create.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)create.$(SRC_CPP)

damage.$(OBJ): damage.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)damage.$(SRC_CPP)

data.$(OBJ): data.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)data.$(SRC_CPP)

date.$(OBJ): date.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)date.$(SRC_CPP)

database.$(OBJ): database.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)database.$(SRC_CPP)

delete.$(OBJ): delete.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)delete.$(SRC_CPP)

distri.$(OBJ): distri.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)distri.$(SRC_CPP)

dof.$(OBJ): dof.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)dof.$(SRC_CPP)

elasti.$(OBJ): elasti.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)elasti.$(SRC_CPP)

elem.$(OBJ): elem.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)elem.$(SRC_CPP)

error.$(OBJ): error.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)error.$(SRC_CPP)

extrude.$(OBJ): extrude.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)extrude.$(SRC_CPP)

failure.$(OBJ): failure.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)failure.$(SRC_CPP)

filter.$(OBJ): filter.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)filter.$(SRC_CPP)

force.$(OBJ): force.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)force.$(SRC_CPP)

general.$(OBJ): general.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)general.$(SRC_CPP)

generate.$(OBJ): generate.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)generate.$(SRC_CPP)

geometry.$(OBJ): geometry.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)geometry.$(SRC_CPP)

groundda.$(OBJ): groundda.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)groundda.$(SRC_CPP)

groundfl.$(OBJ): groundfl.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)groundfl.$(SRC_CPP)

group.$(OBJ): group.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)group.$(SRC_CPP)

hyperela.$(OBJ): hyperela.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)hyperela.$(SRC_CPP)

$(HYPO_OBJ): $(HYPO_SRC)
	$(COMPILER_C) $(COMPILER_FLAGS) $(HYPO_SRC)

hypoplas.$(OBJ): hypoplas.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)hypoplas.$(SRC_CPP)

initia.$(OBJ): initia.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)initia.$(SRC_CPP)

input.$(OBJ): input.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)input.$(SRC_CPP)

integra.$(OBJ): integra.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)integra.$(SRC_CPP)

intersec.$(OBJ): intersec.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)intersec.$(SRC_CPP)

inverse.$(OBJ): inverse.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)inverse.$(SRC_CPP)

locate.$(OBJ): locate.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)locate.$(SRC_CPP)

macro.$(OBJ): macro.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)macro.$(SRC_CPP)

map.$(OBJ): map.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)map.$(SRC_CPP)

mat_diff.$(OBJ): mat_diff.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)mat_diff.$(SRC_CPP)

materi.$(OBJ): materi.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)materi.$(SRC_CPP)

math.$(OBJ): math.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)math.$(SRC_CPP)

maxwell.$(OBJ): maxwell.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)maxwell.$(SRC_CPP)

membrane.$(OBJ): membrane.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)membrane.$(SRC_CPP)

merge.$(OBJ): merge.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)merge.$(SRC_CPP)

mesh.$(OBJ): mesh.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)mesh.$(SRC_CPP)

miscel.$(OBJ): miscel.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)miscel.$(SRC_CPP)

new_mesh.$(OBJ): new_mesh.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)new_mesh.$(SRC_CPP)

node.$(OBJ): node.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)node.$(SRC_CPP)

nonloc.$(OBJ): nonloc.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)nonloc.$(SRC_CPP)

order.$(OBJ): order.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)order.$(SRC_CPP)

plasti.$(OBJ): plasti.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)plasti.$(SRC_CPP)

plasti_i.$(OBJ): plasti_i.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)plasti_i.$(SRC_CPP)

point_el.$(OBJ): point_el.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)point_el.$(SRC_CPP)

polynom.$(OBJ): polynom.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)polynom.$(SRC_CPP)

post.$(OBJ): post.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)post.$(SRC_CPP)

pri.$(OBJ): pri.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)pri.$(SRC_CPP)

print_db.$(OBJ): print_db.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)print_db.$(SRC_CPP)

print_da.$(OBJ): print_da.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)print_da.$(SRC_CPP)

print_dx.$(OBJ): print_dx.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)print_dx.$(SRC_CPP)

print_el.$(OBJ): print_el.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)print_el.$(SRC_CPP)

print_gi.$(OBJ): print_gi.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)print_gi.$(SRC_CPP)

print_g5.$(OBJ): print_g5.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)print_g5.$(SRC_CPP)

print_g6.$(OBJ): print_g6.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)print_g6.$(SRC_CPP)

print_gm.$(OBJ): print_gm.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)print_gm.$(SRC_CPP)

print_hi.$(OBJ): print_hi.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)print_hi.$(SRC_CPP)

print_ma.$(OBJ): print_ma.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)print_ma.$(SRC_CPP)

print_pl.$(OBJ): print_pl.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)print_pl.$(SRC_CPP)

print_rs.$(OBJ): print_rs.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)print_rs.$(SRC_CPP)

print_te.$(OBJ): print_te.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)print_te.$(SRC_CPP)

print_un.$(OBJ): print_un.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)print_un.$(SRC_CPP)

print_vt.$(OBJ): print_vt.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)print_vt.$(SRC_CPP)

project.$(OBJ): project.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)project.$(SRC_CPP)

range.$(OBJ): range.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)range.$(SRC_CPP)

refine_g.$(OBJ): refine_g.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)refine_g.$(SRC_CPP)

refine_l.$(OBJ): refine_l.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)refine_l.$(SRC_CPP)

remesh.$(OBJ): remesh.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)remesh.$(SRC_CPP)

renumber.$(OBJ): renumber.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)renumber.$(SRC_CPP)

repeat.$(OBJ): repeat.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)repeat.$(SRC_CPP)

restart.$(OBJ): restart.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)restart.$(SRC_CPP)

slide.$(OBJ): slide.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)slide.$(SRC_CPP)

so.$(OBJ): so.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)so.$(SRC_CPP)

so_bicg.$(OBJ): so_bicg.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)so_bicg.$(SRC_CPP)

#so_petsc.$(OBJ): so_petsc.$(SRC_C) tochnog.h
#	$(COMPILER_C) $(COMPILER_FLAGS) so_petsc.$(SRC_C)

split.$(OBJ): split.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)split.$(SRC_CPP)

spring.$(OBJ): spring.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)spring.$(SRC_CPP)

stress.$(OBJ): stress.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)stress.$(SRC_CPP)

$(SYS_FILE).$(OBJ): $(SYS_FILE).$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)$(SYS_FILE).$(SRC_CPP)

tendon.$(OBJ): tendon.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)tendon.$(SRC_CPP)

time.$(OBJ): time.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)time.$(SRC_CPP)

tn.$(OBJ): tn.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)tn.$(SRC_CPP)

top.$(OBJ): top.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)top.$(SRC_CPP)

truss.$(OBJ): truss.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)truss.$(SRC_CPP)

umat.$(OBJ): umat.c
	$(COMPILER_C) $(COMPILER_FLAGS) umat.c

unknown.$(OBJ): unknown.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)unknown.$(SRC_CPP)

user.$(OBJ): user.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)user.$(SRC_CPP)

viscoela.$(OBJ): viscoela.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)viscoela.$(SRC_CPP)

visconon.$(OBJ): visconon.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)visconon.$(SRC_CPP)

viscosit.$(OBJ): viscosit.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)viscosit.$(SRC_CPP)

volume.$(OBJ): volume.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)volume.$(SRC_CPP)

wave.$(OBJ): wave.$(SRC_CPP) tochnog.h
	$(COMPILER_CPP) $(COMPILER_FLAGS) $(BCPP) $(VCPP)wave.$(SRC_CPP)

clean:
	rm -f hip hop tmp.* *.log *.dbs *.aux *.his *.inp *.ps *tngid* *flavia* batch* *.phy *.bon *.cmd *.inp *.dx *.tmp *.inp *.rgb *.jpg *.attr *.plt *.scr *.out *.dvd *.vtk vtn* *.o *.0
