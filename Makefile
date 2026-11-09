CC := gcc

TARGET_NAME := openxr_loader.dll
DEF_FILE := src/openxr_loader.def

SRC_GUI := src/gui.c src/main.c src/Quaternion.c
SRC_CONFIG_ONLY := src/main.c src/Quaternion.c

OBJDIR_DEBUG := obj/Debug
OBJDIR_RELEASE_GUI := obj/Release-GUI
OBJDIR_RELEASE_CONFIG_ONLY := obj/Release-ConfigOnly
OBJDIR_LAYER_DEMO := obj/LayerDemo

OBJ_DEBUG := $(SRC_GUI:%.c=$(OBJDIR_DEBUG)/%.o)
OBJ_RELEASE_GUI := $(SRC_GUI:%.c=$(OBJDIR_RELEASE_GUI)/%.o)
OBJ_RELEASE_CONFIG_ONLY := $(SRC_CONFIG_ONLY:%.c=$(OBJDIR_RELEASE_CONFIG_ONLY)/%.o)
OBJ_LAYER_DEMO := $(OBJDIR_LAYER_DEMO)/src/openxr_layer_demo.o

TARGET_DEBUG := $(OBJDIR_DEBUG)/$(TARGET_NAME)
TARGET_RELEASE_GUI := $(OBJDIR_RELEASE_GUI)/$(TARGET_NAME)
TARGET_RELEASE_CONFIG_ONLY := $(OBJDIR_RELEASE_CONFIG_ONLY)/$(TARGET_NAME)
TARGET_LAYER_DEMO := $(OBJDIR_LAYER_DEMO)/openxr_api_layer_demo.dll

OPENXR_INCLUDE ?=
OPENXR_LIB ?=
DEBUG_OUTPUT_DLL ?=
RELEASE_OUTPUT_DLL ?=
CONFIG_ONLY_OUTPUT_DLL ?=

CSTD := -std=c11
COMMON_WARN := -Wall
COMMON_FLAGS := $(COMMON_WARN) -fexceptions -DBUILD_DLL -march=core2 -m64 $(CSTD)

ifeq ($(strip $(OPENXR_INCLUDE)),)
INCLUDE_FLAGS :=
else
INCLUDE_FLAGS := -idirafter $(OPENXR_INCLUDE)
endif

ifeq ($(strip $(OPENXR_LIB)),)
LIB_DIR_FLAGS :=
else
LIB_DIR_FLAGS := -L$(OPENXR_LIB)
endif

ifeq ($(strip $(DEBUG_OUTPUT_DLL)),)
OUT_DEBUG := $(TARGET_DEBUG)
else
OUT_DEBUG := $(DEBUG_OUTPUT_DLL)
endif

ifeq ($(strip $(RELEASE_OUTPUT_DLL)),)
OUT_RELEASE_GUI := $(TARGET_RELEASE_GUI)
else
OUT_RELEASE_GUI := $(RELEASE_OUTPUT_DLL)
endif

ifeq ($(strip $(CONFIG_ONLY_OUTPUT_DLL)),)
OUT_RELEASE_CONFIG_ONLY := $(TARGET_RELEASE_CONFIG_ONLY)
else
OUT_RELEASE_CONFIG_ONLY := $(CONFIG_ONLY_OUTPUT_DLL)
endif

LIBS := -lgdi32 -lkernel32 -lpsapi -luser32
LINK_COMMON := -shared -Wl,--dll -static-libstdc++ -static-libgcc -m64

DEBUG_CFLAGS := $(COMMON_FLAGS) -O0 -g3
RELEASE_CFLAGS := $(COMMON_FLAGS) -O2
RELEASE_CONFIG_ONLY_CFLAGS := $(RELEASE_CFLAGS) -DNO_GUI
LAYER_DEMO_CFLAGS := $(COMMON_FLAGS) -O0 -g3

.PHONY: all dll_debug dll_release dll_release_gui dll_release_config_only layer_demo clean

all: dll_release

dll_debug: $(OUT_DEBUG)

dll_release: dll_release_gui dll_release_config_only

dll_release_gui: $(OUT_RELEASE_GUI)

dll_release_config_only: $(OUT_RELEASE_CONFIG_ONLY)

layer_demo: $(TARGET_LAYER_DEMO)

$(OBJDIR_DEBUG) $(OBJDIR_RELEASE_GUI) $(OBJDIR_RELEASE_CONFIG_ONLY) $(OBJDIR_LAYER_DEMO):
	mkdir -p $@

$(OBJDIR_DEBUG)/%.o: %.c | $(OBJDIR_DEBUG)
	mkdir -p $(dir $@)
	$(CC) $(DEBUG_CFLAGS) $(INCLUDE_FLAGS) -c $< -o $@

$(OBJDIR_RELEASE_GUI)/%.o: %.c | $(OBJDIR_RELEASE_GUI)
	mkdir -p $(dir $@)
	$(CC) $(RELEASE_CFLAGS) $(INCLUDE_FLAGS) -c $< -o $@

$(OBJDIR_RELEASE_CONFIG_ONLY)/%.o: %.c | $(OBJDIR_RELEASE_CONFIG_ONLY)
	mkdir -p $(dir $@)
	$(CC) $(RELEASE_CONFIG_ONLY_CFLAGS) $(INCLUDE_FLAGS) -c $< -o $@

$(OBJDIR_LAYER_DEMO)/%.o: %.c | $(OBJDIR_LAYER_DEMO)
	mkdir -p $(dir $@)
	$(CC) $(LAYER_DEMO_CFLAGS) $(INCLUDE_FLAGS) -c $< -o $@

$(OUT_DEBUG): $(OBJ_DEBUG) $(DEF_FILE)
	$(CC) $(LINK_COMMON) $(LIB_DIR_FLAGS) $(OBJ_DEBUG) $(DEF_FILE) -o "$@" $(LIBS)

$(OUT_RELEASE_GUI): $(OBJ_RELEASE_GUI) $(DEF_FILE)
	$(CC) $(LINK_COMMON) $(LIB_DIR_FLAGS) $(OBJ_RELEASE_GUI) $(DEF_FILE) -o "$@" -s $(LIBS)

$(OUT_RELEASE_CONFIG_ONLY): $(OBJ_RELEASE_CONFIG_ONLY) $(DEF_FILE)
	$(CC) $(LINK_COMMON) $(LIB_DIR_FLAGS) $(OBJ_RELEASE_CONFIG_ONLY) $(DEF_FILE) -o "$@" -s $(LIBS)

$(TARGET_LAYER_DEMO): $(OBJ_LAYER_DEMO)
	$(CC) $(LINK_COMMON) $(LIB_DIR_FLAGS) $(OBJ_LAYER_DEMO) -o "$@"

clean:
	rm -rf obj
