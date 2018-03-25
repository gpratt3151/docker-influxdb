#!/bin/bash
trap continue SIGINT

continue() {
  # Simulate deploying an upgrade
  echo
  echo "Deploying upgrade"
  curl -XPOST "http://localhost:8086/write?db=mydb&precision=s" \
--data-binary 'events title="Deployed v10.2.0",text="<a href='https://github.com'>Release notes</a>",tags="Std Change,Servers,Infra,Upgrade,gpratt" '$(date +%s)
  echo "Rebooting"
  sleep 5
  # Simulate reboot
  curl -XPOST "http://localhost:8086/write?db=mydb" \
  -d "cpu,host=server01,region=uswest load=0 $(date +%s)000000000"

  echo "Partially fixed..."
  # Simulate partial fix
  for i in 1 2 3 4 5 6
  do
    sleep 5
    LOAD=$(curl -s 'https://www.random.org/integers/?num=1&min=40&max=49&col=1&base=10&format=plain&rnd=new')
    curl -XPOST "http://localhost:8086/write?db=mydb" \
    -d "cpu,host=server01,region=uswest load=${LOAD} $(date +%s)000000000"
  done

  echo "Applying patch"
  curl -XPOST "http://localhost:8086/write?db=mydb&precision=s" \
  --data-binary 'events title="Deployed v10.2.1",text="<a href='https://github.com'>Release notes</a>",tags="Emg Change,Servers,Infra,Patch,amerritt" '$(date +%s)
  echo "Rebooting"
  sleep 5
  # Simulate reboot
  curl -XPOST "http://localhost:8086/write?db=mydb" \
  -d "cpu,host=server01,region=uswest load=0 $(date +%s)000000000"
  sleep 5

  echo "Fixed!"
  while :
  do
    LOAD=$(curl -s 'https://www.random.org/integers/?num=1&min=1&max=29&col=1&base=10&format=plain&rnd=new')
    curl -XPOST "http://localhost:8086/write?db=mydb" \
    -d "cpu,host=server01,region=uswest load=${LOAD} $(date +%s%N)"
    sleep 5
  done
exit
}

# Simulate high CPU
echo "Poor performance..."
echo "Press CTRL-C to continue simulation"
while :
do
  sleep 5
  LOAD=$(curl -s 'https://www.random.org/integers/?num=1&min=75&max=100&col=1&base=10&format=plain&rnd=new')
  curl -XPOST "http://localhost:8086/write?db=mydb" \
  -d "cpu,host=server01,region=uswest load=${LOAD} $(date +%s)000000000"
done
