#!/bin/bash
echo "===== 部署验证报告 =====" > deployment-report.txt
date >> deployment-report.txt

# 检查Rocky Node Exporter
echo -n "Rocky Node Exporter: " >> deployment-report.txt
if curl -m 10 -s http://$ROCKY_IP:9100/metrics 2>/dev/null | grep -q "node_cpu_seconds_total"; then
  echo " UP" >> deployment-report.txt
else
  echo " DOWN" >> deployment-report.txt
fi

# 检查Prometheus Targets
echo -n "Prometheus Targets: " >> deployment-report.txt
if curl -s http://localhost:9090/api/v1/targets | grep -q '"health":"up"'; then
  echo " 全部健康" >> deployment-report.txt
else
  echo "  部分异常" >> deployment-report.txt
fi

# 检查Grafana
echo -n "Grafana服务: " >> deployment-report.txt
if curl -s http://localhost:3000/api/health | grep -q "ok"; then
  echo " 运行中" >> deployment-report.txt
else
  echo " 未就绪" >> deployment-report.txt
fi

# 检查端口
echo -e "\n 检查关键端口监听..." >> deployment-report.txt
for port in 9090 9093 3000 9100; do
  if ss -tln | grep -q ":$port "; then
    echo " 端口 $port: 监听中" >> deployment-report.txt
  else
    echo " 端口 $port: 未监听" >> deployment-report.txt
  fi
done

echo -e "\n 验证完成！详细报告见上方" >> deployment-report.txt
cat deployment-report.txt
