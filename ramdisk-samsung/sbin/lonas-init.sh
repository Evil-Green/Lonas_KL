#!/sbin/busybox sh
#

SYSTEM_DEVICE="/dev/block/mmcblk0p9"

# check if init.d folder under /system/etc exists, and if not create it
if [ ! -d "/system/etc/init.d" ] ; then
/sbin/busybox mount -o remount,rw -t ext4 $SYSTEM_DEVICE /system
  /sbin/busybox mkdir /system/etc/init.d
  /sbin/busybox chmod 755 /system/etc/init.d/*
/sbin/busybox mount -o remount,ro -t ext4 $SYSTEM_DEVICE /system
fi

/sbin/busybox mount -o remount,rw /system
/sbin/busybox mount -t rootfs -o remount,rw rootfs

# Bootanimations
if [ ! -f /data/local/bootanimation.zip ] ; then
	/sbin/bootanimation
elif [ ! -f /system/media/bootanimation.zip ] ; then
	/sbin/bootanimation
else
	/sbin/samsungani
fi


# Remount all partitions with noatime
  for k in $(/sbin/busybox mount | /sbin/busybox grep relatime | /sbin/busybox cut -d " " -f3)
  do
        sync
        /sbin/busybox mount -o remount,noatime $k
  done

# Remount ext4 partitions with optimizations
  for k in $(/sbin/busybox mount | /sbin/busybox grep ext4 | /sbin/busybox cut -d " " -f3)
  do
        sync
        /sbin/busybox mount -o remount,commit=15 $k
  done

# Miscellaneous tweaks
echo "12288" > /proc/sys/vm/min_free_kbytes
echo "1500" > /proc/sys/vm/dirty_writeback_centisecs
echo "200" > /proc/sys/vm/dirty_expire_centisecs

# Tweaks internos
echo "2" > /sys/devices/system/cpu/sched_mc_power_savings
echo "0" > /proc/sys/kernel/randomize_va_space
echo "3" > /sys/module/cpuidle_exynos4/parameters/enable_mask

# SD cards (mmcblk) read ahead tweaks
echo "1024" > /sys/devices/virtual/bdi/179:0/read_ahead_kb
echo "1024" > /sys/devices/virtual/bdi/179:16/read_ahead_kb
echo "512" > /sys/devices/virtual/bdi/default/read_ahead_kb
echo "256" > /sys/block/mmcblk0/bdi/read_ahead_kb
echo "256" > /sys/block/mmcblk1/bdi/read_ahead_kb

# Governor por defecto
echo "lonas" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
# cpu2
echo "500000" > /sys/devices/system/cpu/cpufreq/lonas/hotplug_freq_1_1
echo "400000" > /sys/devices/system/cpu/cpufreq/lonas/hotplug_freq_2_0
echo "100" > /sys/devices/system/cpu/cpufreq/lonas/hotplug_rq_1_1
echo "100" > /sys/devices/system/cpu/cpufreq/lonas/hotplug_rq_2_0

# cpu3
echo "800000" > /sys/devices/system/cpu/cpufreq/lonas/hotplug_freq_2_1
echo "600000" > /sys/devices/system/cpu/cpufreq/lonas/hotplug_freq_3_0
echo "200" > /sys/devices/system/cpu/cpufreq/lonas/hotplug_rq_2_1
echo "200" > /sys/devices/system/cpu/cpufreq/lonas/hotplug_rq_3_0

# cpu4
echo "800000" > /sys/devices/system/cpu/cpufreq/lonas/hotplug_freq_3_1
echo "600000" > /sys/devices/system/cpu/cpufreq/lonas/hotplug_freq_4_0
echo "300" > /sys/devices/system/cpu/cpufreq/lonas/hotplug_rq_3_1
echo "300" > /sys/devices/system/cpu/cpufreq/lonas/hotplug_rq_4_0

# IPv6 privacy tweak
echo "2" > /proc/sys/net/ipv6/conf/all/use_tempaddr

# TCP tweaks
echo "2" > /proc/sys/net/ipv4/tcp_syn_retries
echo "2" > /proc/sys/net/ipv4/tcp_synack_retries
echo "10" > /proc/sys/net/ipv4/tcp_fin_timeout

for i in $(/sbin/busybox find /sys/block/mmc*)
do 
echo "row" > $i/queue/scheduler
echo "0" > $i/queue/add_random
echo "0" > $i/queue/rotational
echo "8192" > $i/queue/nr_requests
echo "0" > $i/queue/iostats
echo "1" > $i/queue/iosched/back_seek_penalty
echo "2" > $i/queue/iosched/slice_idle
done

# Turn off debugging for certain modules
echo "0" > /sys/module/wakelock/parameters/debug_mask
echo "0" > /sys/module/userwakelock/parameters/debug_mask
echo "0" > /sys/module/earlysuspend/parameters/debug_mask
echo "0" > /sys/module/alarm/parameters/debug_mask
echo "0" > /sys/module/alarm_dev/parameters/debug_mask
echo "0" > /sys/module/binder/parameters/debug_mask
echo "0" > /sys/module/lowmemorykiller/parameters/debug_level
echo "0" > /sys/module/mali/parameters/mali_debug_level
echo "0" > /sys/module/ump/parameters/ump_debug_level

echo "8192,10240,12288,15360,20480,24576" > /sys/module/lowmemorykiller/parameters/minfree

/sbin/busybox mount -t rootfs -o remount,ro rootfs
/sbin/busybox mount -o remount,ro /system
