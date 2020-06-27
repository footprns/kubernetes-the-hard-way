install core-dns:
  cmd.run:
    - name: kubectl apply -f https://raw.githubusercontent.com/mmumshad/kubernetes-the-hard-way/master/deployments/coredns.yaml
    - cwd: /home/ubuntu