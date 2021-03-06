srcdir := src
protodir := src/proto
gendir := gen
builddir := build
outdir := bin

confdir := configs
scriptdir := scripts

confinstalldir := /etc/cloudrun
scriptinstalldir := /usr/local/bin

CC ?= gcc
CXX ?= g++
PROTOC ?= protoc
LD = g++
CPREFLAGS := -D_FILE_OFFSET_BITS=64 -I $(gendir) -I $(srcdir)
CFLAGS := -O2 -fPIC $(CPREFLAGS)
CXXFLAGS := $(CFLAGS)
LDFLAGS = -fPIC -l:libssl.so.1.0.0 -l:libcrypto.so.1.0.0 -lprotobuf -lgrpc++ -pthread

CSOURCES := $(shell find $(srcdir) -type f -name *.c)
CXXSOURCES := $(shell find $(srcdir) -type f -name *.cpp)
PROTOSOURCES := src/proto/filesystem.proto src/proto/remotefs.proto

COBJS := $(CSOURCES:$(srcdir)/%.c=$(builddir)/%.c.o)
CXXOBJS := $(CXXSOURCES:$(srcdir)/%.cpp=$(builddir)/%.cxx.o)
CDEPS := $(SOURCES:$(srcdir)/%.c=$(builddir)/%.c.d)
CXXDEPS := $(CXXSOURCES:$(srcdir)/%.cpp=$(builddir)/%.cxx.d)

PROTOHEAD := $(PROTOSOURCES:$(srcdir)/%.proto=$(gendir)/%.pb.h)
PROTOOBJS := $(PROTOSOURCES:$(srcdir)/%.proto=$(builddir)/%.pb.o) $(PROTOSOURCES:$(srcdir)/%.proto=$(builddir)/%.grpc.pb.o)
PROTOCFILES := $(PROTOSOURCES:$(srcdir)/%.proto=$(gendir)/%.pb.cc)

TARGET := $(outdir)/cloudrun-client-daemon
INSTALLTARGET := /usr/local/bin/cloudrun-client-daemon

CONFSOURCES := $(shell find $(confdir) -type f)
CONFINSTALLTARGETS := $(CONFSOURCES:$(confdir)/%=$(confinstalldir)/%)
SCRIPTSOURCES := $(shell find $(scriptdir) -type f)
SCRIPTNSTALLTARGETS :=  $(SCRIPTSOURCES:$(scriptdir)/%=$(scriptinstalldir)/%)

all: $(TARGET)

generated: $(PROTOHEAD)
 
$(TARGET): $(COBJS) $(CXXOBJS) $(PROTOOBJS)
	@echo Linking $@
	@mkdir -p $(outdir)
	$(LD) $+ $(LDFLAGS) -o $@

$(builddir)/%.pb.o: generated
	@echo Building $@
	@mkdir -p "$(@D)"
	$(CXX) $(gendir)/$*.pb.cc $(CXXFLAGS) -c -o $@

$(gendir)/%.pb.h: $(srcdir)/%.proto
	@echo Generating proto $@
	@mkdir -p "$(@D)"
	$(PROTOC) $< -I $(protodir) --grpc_out=$(@D) --plugin=protoc-gen-grpc=`which grpc_cpp_plugin`
	$(PROTOC) $< -I $(protodir) --cpp_out=$(@D)
 
$(builddir)/%.c.o: $(srcdir)/%.c generated $(builddir)/%.c.d
	@echo Building $@
	@mkdir -p "$(@D)"
	$(CC) $(CFLAGS) -c -o $@ $<

$(builddir)/%.cxx.o: $(srcdir)/%.cpp generated $(builddir)/%.cxx.d
	@echo Building $@
	@mkdir -p "$(@D)"
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(builddir)/%.c.d: $(srcdir)/%.c generated
	@echo Generating dependency list for $<
	@mkdir -p "$(@D)"
	@echo -n "$(@D)/" > $@
	$(CC) -MM -MP $(CPREFLAGS) $< | sed -r "s^.o:^.o $@ :^" >> $@

$(builddir)/%.cxx.d: $(srcdir)/%.cpp generated
	@echo Generating dependency list for $<
	@mkdir -p "$(@D)"
	@echo -n "$(@D)/" > $@
	$(CXX) -MM -MP $(CPREFLAGS) $< | sed -r "s^.o:^.o $@ :^" >> $@

clean:
	rm -rf $(gendir)
	rm -rf $(builddir)
	rm -rf $(outdir)

$(INSTALLTARGET): $(TARGET)
	@echo Installing $<
	cp $(TARGET) $(INSTALLTARGET)

$(confinstalldir)/%: $(confdir)/%
	@echo Installing $<
	@mkdir -p "$(@D)"
	cp $< $@

$(scriptinstalldir)/%: $(scriptdir)/%
	@echo Installing $<
	@mkdir -p "$(@D)"
	cp $< $@

install: $(INSTALLTARGET) $(CONFINSTALLTARGETS) $(SCRIPTNSTALLTARGETS)

uninstall:
	rm -f $(INSTALLTARGET)
	rm -f $(CONFINSTALLTARGETS)
	rmdir --ignore-fail-on-non-empty $(confinstalldir)
	rm -f $(SCRIPTNSTALLTARGETS)

.PHONY: all clean install uninstall
.SECONDARY:
.SUFFIXES:
-include $(CDEPS) $(CXXDEPS)
 
