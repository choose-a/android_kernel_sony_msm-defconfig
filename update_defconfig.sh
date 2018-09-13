ANDROID_ROOT=../../../../../../..
cd $ANDROID_ROOT;
ANDROID_ROOT=$(pwd);
export ANDROID_ROOT
export KERNEL_TOP=$ANDROID_ROOT/kernel/sony/msm
export KERNEL_CFG=arch/arm64/configs/sony
export KERNEL_TMP=$ANDROID_ROOT/out/kernel-tmp
export BUILD="make O=$KERNEL_TMP ARCH=arm64 CROSS_COMPILE=$CROSS_COMPILE -j$(nproc)"

LOIRE="suzu kugo blanc"
TONE="dora kagura keyaki"
YOSHINO="lilac maple poplar"
NILE="discovery pioneer"
TAMA="akari apollo"

PLATFORMS="loire tone yoshino nile tama"

cd $KERNEL_TOP

for platform in $PLATFORMS; do \

case $platform in
loire)
    DEVICE=$LOIRE;
    DRM="false";;
tone)
    DEVICE=$TONE;
    DRM="false";;
yoshino)
    DEVICE=$YOSHINO;
    DRM="false";;
nile)
    DEVICE=$NILE;
    DRM="false";;
tama)
    DEVICE=$TAMA;
    DRM="true";;
esac

echo "================================================="
echo "Your Environment:"
echo "ANDROID_ROOT: ${ANDROID_ROOT}"
echo "KERNEL_TOP  : ${KERNEL_TOP}"
echo "KERNEL_CFG  : ${KERNEL_CFG}"
echo "KERNEL_TMP  : ${KERNEL_TMP}"
for device in $DEVICE; do \
    ret=$(rm -rf ${KERNEL_TMP} 2>&1);
    ret=$(mkdir -p ${KERNEL_TMP} 2>&1);
    if [ ! -f $KERNEL_TMP ]; then
        echo "Check your environment";
        echo "ERROR: $ret";
        exit 1;
    fi
    echo "================================================="
    echo "Platform -> ${platform} :: Device -> $device"
    echo "Running scripts/kconfig/merge_config.sh ..."
    if [ $DRM = "true" ]; then
        ret=$(ARCH=arm64 O=${KERNEL_TMP} scripts/kconfig/merge_config.sh \
            ${KERNEL_CFG}/base_drm_defconfig \
            ${KERNEL_CFG}/base_${platform}_common_defconfig \
            ${KERNEL_CFG}/base_${platform}"_"${device}\_defconfig \
            ${KERNEL_CFG}/android-base.config \
            ${KERNEL_CFG}/android-base-arm64.config \
            ${KERNEL_CFG}/android-recommended.config \
            ${KERNEL_CFG}/android-extra.config 2>&1);
    else
        ret=$(ARCH=arm64 O=${KERNEL_TMP} scripts/kconfig/merge_config.sh \
            ${KERNEL_CFG}/base_fb_defconfig \
            ${KERNEL_CFG}/base_${platform}_common_defconfig \
            ${KERNEL_CFG}/base_${platform}"_"${device}\_defconfig \
            ${KERNEL_CFG}/android-base.config \
            ${KERNEL_CFG}/android-base-arm64.config \
            ${KERNEL_CFG}/android-recommended.config \
            ${KERNEL_CFG}/android-extra.config 2>&1);
    fi

    case "$ret" in
        *"error"*|*"ERROR"*) echo "ERROR: $ret"; exit 1;;
    esac
    echo "Building new defconfig ..."
    ret=$(${BUILD} savedefconfig 2>&1);
    case "$ret" in
        *"error"*|*"ERROR"*) echo "ERROR: $ret"; exit 1;;
    esac
    mv $KERNEL_TMP/defconfig ./arch/arm64/configs/aosp_$platform"_"$device\_defconfig
done
done

echo "================================================="
echo "Clean up environment"
ret=$(make mrproper 2>&1)
echo "Done!"
rm -rf $KERNEL_TMP
unset ANDROID_ROOT
unset KERNEL_TOP
unset KERNEL_CFG
unset KERNEL_TMP
unset BUILD
