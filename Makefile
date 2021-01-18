TARGET := iphone:clang:latest:13.0
INSTALL_TARGET_PROCESSES = SpringBoard

ARCHS = arm64 arm64e

DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PopLockAndDropIt

PopLockAndDropIt_FILES = Tweak.xm
PopLockAndDropIt_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
PopLockAndDropIt_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
include $(THEOS_MAKE_PATH)/aggregate.mk