# Trabalho Final - Fundamentos de DevOps

**Aluno:** Hugo Manoél de Souza Lopes  
**Curso:** Bacharelado em Sistemas de Informação (5º Período) - Instituto Federal Catarinense (Campus Araquari)  
**Disciplina:** Fundamentos de DevOps

## 1. Introdução

Este projeto consiste no desenvolvimento de uma infraestrutura automatizada e na implementação de uma esteira de deploy contínuo utilizando práticas GitOps. O objetivo é subir uma aplicação Full-Stack (Backend em Python/Django, Frontend em HTML/JS e Banco de Dados PostgreSQL) garantindo alta disponibilidade, automação e roteamento reverso.

## 2. Escolha do Ambiente

*   **Ambiente:** Nuvem (AWS Learner Lab).
*   **Justificativa:** A nuvem proporciona flexibilidade, escalabilidade sob demanda e integração perfeita com ferramentas de Infraestrutura como Código (IaC).
*   **Instâncias Criadas:** Foram provisionadas 4 instâncias EC2 rodando Ubuntu 22.04 LTS:
    *   **DevOps-ControlPlane (t2.medium):** Responsável pelo gerenciamento do cluster (Master).
    *   **DevOps-Worker-1, 2 e 3 (t2.micro):** Nós de trabalho para execução dos contêineres.

## 3. Provisionamento

*   **Ferramentas:** Terraform (para criação das instâncias EC2 e Security Groups) e Ansible (para padronização e configurações iniciais dos servidores).
*   **Desafios e Soluções:** O gerenciamento de IPs dinâmicos do AWS Learner Lab foi solucionado através de atualizações automatizadas no inventário do Ansible e gerenciamento do ciclo de vida das AMIs no Terraform (`lifecycle ignore_changes`).

## 4. Cluster Kubernetes

*   **Ferramenta:** Utilizou-se o K3s por ser uma distribuição leve do Kubernetes, ideal para ambientes de estudo e produção com recursos limitados.
*   **Configuração:** O cluster possui 1 Control Plane e 3 Workers integrados. O roteamento de entrada é feito nativamente pelo Traefik.

## 5. GitOps com ArgoCD

*   **Instalação:** O ArgoCD foi implantado diretamente no cluster K3s.
*   **Estratégia GitOps:** A aplicação monitora este repositório Git. Qualquer alteração nos arquivos YAML da pasta `/k8s` reflete automaticamente no cluster através da política de Auto-Sync, Prune e Self-Heal.

## 6. Integração Contínua (CI)

Implementei uma esteira de **CI (Continuous Integration)** utilizando **GitHub Actions** para elevar o nível de automação e segurança:

*   **Automação:** Sempre que um novo código é enviado para o repositório (`git push`), o GitHub Actions dispara automaticamente o *build* da imagem Docker e o *push* para o Docker Hub.
*   **Segurança:** Utilizamos **GitHub Secrets** para armazenar as credenciais (`DOCKERHUB_USERNAME` e `DOCKERHUB_TOKEN`), garantindo que dados sensíveis não sejam expostos.
*   **Fluxo Completo:** A integração une a **CI (GitHub Actions)**, que gerencia a geração das imagens, à **CD (ArgoCD)**, que garante a sincronização contínua do estado do cluster com o repositório GitOps.

## 7. Aplicação e Acesso

A aplicação é dividida em serviços interligados:
*   **Backend:** Django (Python), exposto na porta 8000.
*   **Frontend:** HTML/CSS/JS servido via Nginx, exposto na porta 80.
*   **Banco de Dados:** PostgreSQL 15-alpine.
*   **Visualização de Banco:** Adminer implementado.

**Como Acessar:**
*   **Frontend:** `http://<IP-DO-CONTROL-PLANE>/`
*   **Backend (API):** `http://<IP-DO-CONTROL-PLANE>/api/items/`
*   **ArgoCD:** `sudo k3s kubectl port-forward svc/argocd-server -n argocd 8080:443` -> `https://localhost:8080`
*   **Adminer:** `sudo k3s kubectl port-forward svc/app-adminer-svc 8082:8080` -> `http://localhost:8082`

## 8. Conclusão

O desenvolvimento do projeto consolidou a importância de tratar a infraestrutura como código (IaC) e a eficácia do paradigma GitOps. As maiores dificuldades envolveram o roteamento de caminhos relativos no frontend para comunicação correta com a API através do Traefik. A implementação de uma esteira completa de CI/CD (GitHub Actions + ArgoCD) permitiu um fluxo de trabalho profissional, onde cada alteração no código é automaticamente integrada, validada e implantada, garantindo um processo de entrega contínua robusto e seguro.