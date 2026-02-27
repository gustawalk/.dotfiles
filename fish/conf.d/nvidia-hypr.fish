set -Ux GBM_BACKEND nvidia-drm
set -Ux __GLX_VENDOR_LIBRARY_NAME nvidia
set -Ux __GL_VRR_ALLOWED 1
set -Ux WLR_NO_HARDWARE_CURSORS 1
set -Ux WLR_RENDERER vulkan
set -Ux VK_ICD_FILENAMES /usr/share/vulkan/icd.d/nvidia_icd.json
