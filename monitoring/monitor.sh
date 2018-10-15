#!/bin/bash
# 定时收集java服务metrics

ip=`hostname -I| awk '{print $1}'`

memory_total=`free | grep Mem | awk '{print $2}'`
memory_used=`free | grep Mem | awk '{print $3}'`
memory_free=`free | grep Mem | awk '{print $4}'`
memory_available=`free | grep Mem | awk '{print $7}'`
memory_usage_percent=`echo "scale=2;$memory_used/$memory_total" | bc`
echo $memory_usage_percent
curl -i -X POST http://10.19.18.45:8086/write?db=monitordb --data-binary "memory/memory_total,ip=$ip value=$memory_total"
curl -i -X POST http://10.19.18.45:8086/write?db=monitordb --data-binary "memory/memory_used,ip=$ip value=$memory_used"
curl -i -X POST http://10.19.18.45:8086/write?db=monitordb --data-binary "memory/memory_free,ip=$ip value=$memory_free"
curl -i -X POST http://10.19.18.45:8086/write?db=monitordb --data-binary "memory/memory_available,ip=$ip value=$memory_available"
curl -i -X POST http://10.19.18.45:8086/write?db=monitordb --data-binary "memory/memory_usage_percent,ip=$ip value=$memory_usage_percent"



load_average=`top -n 1 -b | grep average | awk -F 'average:' '{print $2}' | awk '{print $1}' | sed s/,/""/g`
curl -i -X POST http://10.19.18.45:8086/write?db=monitordb --data-binary "average/average,ip=$ip value=$load_average"
CpuIdle=`vmstat 1 5 |sed -n '3,$p' |awk '{x = x + $15} END {print x/5}' |awk -F. '{print $1}'`
cpu_usage_percent=`echo "scale=2;100-$CpuIdle" | bc`
curl -i -X POST http://10.19.18.45:8086/write?db=monitordb --data-binary "cpu/cpu_usage_percent,ip=$ip value=$cpu_usage_percent"


df | grep -v Filesystem | while read lines
do
  disk_name=`echo $lines | awk '{print $1}'`
  disk_used=`echo $lines | awk '{print $3}'`
  disk_path=`echo $lines | awk '{print $6}'`
  disk_usage=`echo $lines | awk '{print $5}' | sed s#%#""#g`
  disk_usage_percent=`echo "scale=2;$disk_usage/100" | bc`
  echo disk_usage-------------------------------- $disk_usage
  echo disk_used-------------------------------- $disk_used
  curl -i -X POST http://10.19.18.45:8086/write?db=monitordb --data-binary "disk/disk_usage_percent,ip=$ip,disk_name=$disk_name,disk_path=$disk_path value=$disk_usage_percent"
  curl -i -X POST http://10.19.18.45:8086/write?db=monitordb --data-binary "disk/disk_used,ip=$ip,disk_name=$disk_name,disk_path=$disk_path value=$disk_used"
done

echo done
