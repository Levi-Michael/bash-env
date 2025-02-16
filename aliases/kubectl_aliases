### KUBECTL ALIASES ###
alias k='kubectl'
alias kubectl='kubectl'
alias k9s='k9s'
alias kubens='kubens'
alias kns='kubens'
alias ke='kubectl exec -it'
alias ka='kubectl apply -f'
alias kg='kubectl get'
alias kd='kubectl describe'
alias kdel='kubectl delete'


### KUBECTL LOGS ###
alias kl='kubectl logs -f'
alias kl1='kubectl logs -f $(kubectl get pods -o custom-columns=:metadata.name --no-headers | sed -n 1p)'
alias kl2='kubectl logs -f $(kubectl get pods -o custom-columns=:metadata.name --no-headers | sed -n 2p)'
alias kl3='kubectl logs -f $(kubectl get pods -o custom-columns=:metadata.name --no-headers | sed -n 3p)'
alias kl4='kubectl logs -f $(kubectl get pods -o custom-columns=:metadata.name --no-headers | sed -n 4p)'
alias kl5='kubectl logs -f $(kubectl get pods -o custom-columns=:metadata.name --no-headers | sed -n 5p)'


### DEPLOYMENT ###
alias kgd='kubectl get deployment'
alias kdd='kubectl describe deployment'
alias kdeld='kubectl delete deployment'
alias kgpy='kubectl get deployment -o yaml'
alias kgpj='kubectl get deployment -o json'


### PODS ###
alias kgp='kubectl get pods'
alias kgpw='kubectl get pods -o wide'
alias kgpy='kubectl get pods -o yaml'
alias kgpj='kubectl get pods -o json'
alias kdp='kubectl describe pods'
alias kdp1='kubectl describe pod $(kubectl get pods -o custom-columns=:metadata.name --no-headers | sed -n 1p)'
alias kdp2='kubectl describe pod $(kubectl get pods -o custom-columns=:metadata.name --no-headers | sed -n 2p)'
alias kdp3='kubectl describe pod $(kubectl get pods -o custom-columns=:metadata.name --no-headers | sed -n 3p)'
alias kdp4='kubectl describe pod $(kubectl get pods -o custom-columns=:metadata.name --no-headers | sed -n 4p)'
alias kdp5='kubectl describe pod $(kubectl get pods -o custom-columns=:metadata.name --no-headers | sed -n 5p)'
alias kdelp='kubectl delete pods'


### SECRETS ###
alias kgs='kubectl get secrets'
alias kds='kubectl describe secrets'
alias kgsy='kubectl get secrets -o yaml'
alias kgsj='kubectl get secrets -o json'


### SERVICE ###
alias kgsvc='kubectl get service'
alias kdsvc='kubectl describe service'
alias kdelsvc='kubectl delete service'


### INGRESS ###
alias kgi='kubectl get ingress'
alias kdi='kubectl describe ingress'
alias kdeli='kubectl del ingress'
alias kgiy='kubectl get ingress -o yaml'
alias kgij='kubectl get ingress -o json'


### CONFIG-MAP ###
alias kgcm='kubectl get configmap'
alias kdcm='kubectl describe configmap'
alias kdelcm='kubectl delete configmap'
alias kgcmy='kubectl get configmap -o yaml'
alias kgcmj='kubectl get configmap -o json'


### NAMESPACE ###
alias kgns='kubectl get namespace'
alias kdelns='kubectl delete namespace'
alias kgnsy='kubectl get namespace -o yaml'
alias kgnsj='kubectl get namespace -o json'


### CROSSPLANE ###
alias kgm='kubectl get managed'
