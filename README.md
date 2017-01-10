# Setting up an coreos based Kubernetes Cluster

Before running Ansible on coreos nodes Make sure to have Python interpreter for Ansible

```
git clone https://github.com/rajeshwer/python-coreos.git
cd python-coreos
chmod +x coreos-python.sh
./coreos-python.sh
export PATH=$PATH:/opt/bin
```


```
Git clone https://github.com/rajeshwer/Kubernetes-ansible.git
chmod  +x kubernetesTLS.sh
./kubernetesTLS.sh
```
ssh into one of master node and set path fo KUBECTL bin file

PATH=/opt/local/bin:$PATH;export PATH

Check if the nodes are registerd 

```
core@coreos01 ~ $ sudo kubectl get nodes
NAME           STATUS                     AGE
10.10.191.15   Ready,SchedulingDisabled   4h
10.10.191.16   Ready                      4h
10.10.191.17   Ready                      4h
```

your kubernetes single node cluster is set up on coreos 


