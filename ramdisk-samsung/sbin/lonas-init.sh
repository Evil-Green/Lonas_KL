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

sleep 10
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
echo "70" > /proc/sys/vm/dirty_background_ratio;
echo "90" > /proc/sys/vm/dirty_ratio;
echo "4" > /proc/sys/vm/min_free_order_shift;
echo "1" > /proc/sys/vm/overcommit_memory;
echo "50" > /proc/sys/vm/overcommit_ratio;
echo "128 128" > /proc/sys/vm/lowmem_reserve_ratio;
echo "3" > /proc/sys/vm/page-cluster;
echo "0" > /proc/sys/vm/swappiness

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

# IPv6 privacy tweak
echo "2" > /proc/sys/net/ipv6/conf/all/use_tempaddr

# TCP tweaks
echo "0" > /proc/sys/net/ipv4/tcp_timestamps;
echo "1" > /proc/sys/net/ipv4/tcp_tw_reuse;
echo "1" > /proc/sys/net/ipv4/tcp_sack;
echo "1" > /proc/sys/net/ipv4/tcp_tw_recycle;
echo "1" > /proc/sys/net/ipv4/tcp_window_scaling;
echo "1" > /proc/sys/net/ipv4/tcp_moderate_rcvbuf;
echo "1" > /proc/sys/net/ipv4/route/flush;
echo "2" > /proc/sys/net/ipv4/tcp_syn_retries;
echo "2" > /proc/sys/net/ipv4/tcp_synack_retries;
echo "10" > /proc/sys/net/ipv4/tcp_fin_timeout;
echo "0" > /proc/sys/net/ipv4/tcp_ecn;
echo "524288" > /proc/sys/net/core/wmem_max;
echo "524288" > /proc/sys/net/core/rmem_max;
echo "262144" > /proc/sys/net/core/rmem_default;
echo "262144" > /proc/sys/net/core/wmem_default;
echo "20480" > /proc/sys/net/core/optmem_max;
echo "6144 87380 524288" > /proc/sys/net/ipv4/tcp_wmem;
echo "6144 87380 524288" > /proc/sys/net/ipv4/tcp_rmem;
echo "4096" > /proc/sys/net/ipv4/udp_rmem_min;
echo "4096" > /proc/sys/net/ipv4/udp_wmem_min;

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

# Misc IO Tweaks
echo "524288" > /proc/sys/fs/file-max;
echo "1048576" > /proc/sys/fs/nr_open;
echo "32000" > /proc/sys/fs/inotify/max_queued_events;
echo "256" > /proc/sys/fs/inotify/max_user_instances;
echo "10240" > /proc/sys/fs/inotify/max_user_watches;

# Misc Kernel Tweaks
echo "2048" > /proc/sys/kernel/msgmni;
echo "65536" > /proc/sys/kernel/msgmax;
echo "10" > /proc/sys/fs/lease-break-time;
echo "128" > /proc/sys/kernel/random/read_wakeup_threshold;
echo "256" > /proc/sys/kernel/random/write_wakeup_threshold;
echo "500 512000 64 2048" > /proc/sys/kernel/sem;
echo "2097152" > /proc/sys/kernel/shmall;
echo "268435456" > /proc/sys/kernel/shmmax;
echo "524288" > /proc/sys/kernel/threads-max;

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
