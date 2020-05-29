n=5
port=7001

query=`redis-cli -c -p $port  cluster nodes |awk '{print $3}'`
########
#echo ${query}
for ((i=0;i<$n;i++));
do
if [[ $query == *fail* ]]
then
  echo "[exist cluster node fail or pfail!!!]"
  sleep 1
else
  result=`redis-cli -c -p $port cluster failover`
  ######
  #echo $result
  if [[ $result == "ERR You should send CLUSTER FAILOVER to a slave" ]]
  then
    echo "no need to redis cluster failover"
  else
    echo "redis cluster failover:$result"
  fi
  for ((j=0;j<$n;j++));
  do
  endQuery=`redis-cli -c -p $port cluster nodes|awk 'BEGIN {count=0;} {ip[count] = $2;name[count] = $3;count++;}; END{for (i = 0; i < NR; i++) if (match(name[i],"myself,master")){print ip[i],name[i];break}}'`
  if [[ $endQuery != "" ]]
  then
    echo "result====>>>>"$endQuery
    break;
  fi
  echo "sleep 2..."
  sleep 2
  done
  break;
fi
done
