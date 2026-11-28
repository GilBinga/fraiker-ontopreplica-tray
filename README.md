<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/fraiker-tools-logo-horizontal-dark-bg-h64.png">
  <img alt="Fraiker Tools" src="assets/fraiker-tools-logo-horizontal-light-bg-h64.png">
</picture>

> [!TIP]
> **Gostou? Ajude o desenvolvedor: doe Tibia Coins para o personagem `Fraiker`.**
> No jogo ou no site: Store → Transfer Coins. O menu do ícone tem um atalho que copia o nome. Obrigado!

## Instalação

1. Instale o OnTopReplica ([página de download aqui](https://github.com/LorenzCK/OnTopReplica/releases)).
2. Baixe o zip da [última versão](https://github.com/GilBinga/fraiker-ontopreplica-tray/releases/latest) (em **Assets**, o arquivo `Fraiker-Tools-OnTopReplica-…zip`) e extraia numa pasta fixa, por exemplo `C:\Users\<você>\Projetos\Fraiker Tools`.
3. Dê dois cliques em `Fraiker Tools.vbs`. O ícone do Fraiker Tools (escudo com o "F") aparece perto do relógio.
   Na primeira vez, o ajudante cria atalhos "Fraiker Tools" com o ícone do escudo na própria pasta e no Menu Iniciar. Depois disso, abra por eles.
4. (Opcional) Para ligar junto com o Windows: clique com o botão direito no ícone e marque **Iniciar com o Windows**.

Se o ícone ficar escondido na setinha **^** ao lado do relógio, arraste ele para a barra uma vez.

Se o Windows mostrar um aviso de segurança ao abrir o `.vbs` (arquivo vindo da internet), clique em **Executar**.
Se mesmo assim nada aparecer: clique com o botão direito em `Fraiker Tools.ps1`, escolha **Propriedades**, marque **Desbloquear** e clique em OK.

# OnTopReplica Tray

<img src="assets/fraiker-tools-icon-64.png" alt="" width="64" align="right">

Ajudante para o [OnTopReplica](https://github.com/LorenzCK/OnTopReplica) no Windows.
Abre suas réplicas com um clique e tira elas da barra de tarefas e do Alt-Tab.
Elas continuam visíveis por cima do jogo, e o controle fica num ícone perto do relógio.

Feito para quem usa réplicas do Tibia (barra de vida, cooldowns etc.), mas funciona com qualquer janela.

## O que faz

Clique com o botão direito no ícone perto do relógio:

| Item | O que faz |
|---|---|
| **Abrir / fechar réplicas** (ou duplo clique) | Se houver réplicas abertas, fecha todas. Se não, roda `Abrir réplicas.bat` e esconde as novas da barra e do Alt-Tab |
| Mostrar réplicas na barra | Volta as réplicas para a barra de tarefas e o Alt-Tab |
| Esconder réplicas da barra | Tira as réplicas da barra e do Alt-Tab (útil para as que você abriu por fora do ajudante) |
| Configurar layout (site do Porfz) | Abre no navegador o gerador de `.bat` feito pelo [Porfz Tibia](https://www.youtube.com/@porfztibia) |
| Editar script de abrir | Abre o `.bat` no Bloco de Notas |
| Iniciar com o Windows | Liga ou desliga a abertura do ajudante junto com o Windows (com ✓ = ligado) |
| Atalho na Área de Trabalho | Cria ou remove o atalho "Fraiker Tools" na Área de Trabalho |
| Apoie o desenvolvedor | Copia o nome `Fraiker` para você doar Tibia Coins |
| Sair do ajudante | Fecha as réplicas abertas e o ícone |

O ajudante não fica rodando nada em segundo plano: só age quando você clica.

## Configurando suas réplicas

**Jeito fácil:** use o [Gerador de .bat OnTopReplica para Tibia](https://claude.ai/artifact/6xc44YsEzGBxsgnZK54y6F) (ou pelo menu **Configurar layout**).
Você envia um print do jogo, marca as áreas que viram réplicas, posiciona cada uma e copia o `.bat` pronto.
Ele também importa um `.bat` que você já tenha.
Cole o resultado em `Abrir réplicas.bat` e abra pelo menu **Abrir / fechar réplicas** (se já estiverem abertas, use duas vezes: fecha e abre com o layout novo). O ajudante corrige sozinho o `%%OTR_EXE%%` que o gerador escreve (vira `%OTR_EXE%`) e usa o `.exe` que ele achou, mesmo fora da pasta padrão. Se rodar o `.bat` direto, sem o ajudante, troque `%%OTR_EXE%%` por `%OTR_EXE%` na mão.
Créditos do gerador: [Porfz Tibia](https://www.youtube.com/@porfztibia).

> [!WARNING]
> O ajudante executa o `Abrir réplicas.bat` do jeito que ele estiver. Use só `.bat` feito pelo gerador ou por você, nunca um "layout pronto" mandado por desconhecidos.
> Um layout normal só tem linhas `start "" "%OTR_EXE%" …` com opções `--…`, `taskkill /F /IM OnTopReplica.exe`, `timeout`, `rem`, `@echo off` e `exit`.
> Se aparecer qualquer outra coisa, o ajudante mostra as linhas suspeitas e pergunta antes de rodar (o padrão é **Não**).

**Na mão:** edite `Abrir réplicas.bat` (pelo menu **Editar script de abrir**). Cada bloco `start` é uma réplica:

```bat
start "" "%OTR_EXE%" ^
  --windowTitle="Tibia -" ^
  --region=1753,134,32,32 ^
  --position=787,431 ^
  --size=38,38 ^
  --chromeOff --clickThrough --opacity=179
```

- `--windowTitle`: início do título da janela que será copiada.
- `--region`: `x,y,largura,altura` do pedaço da janela a copiar.
- `--position`: `x,y` onde a réplica aparece na tela.
- `--size`: `largura,altura` da réplica.
- `--chromeOff` (sem borda), `--clickThrough` (o clique passa para o jogo), `--opacity` (0–255).

**As coordenadas que vêm no arquivo são de exemplo**, feitas para uma tela de 1920x1009 com um layout específico. Ajuste para o seu.
Para achar a região, abra o OnTopReplica normalmente, selecione a área com o mouse e anote os números.

## Onde ele procura o OnTopReplica.exe

Nesta ordem:

1. A variável de ambiente `OTR_EXE`, se você definir uma.
2. Um OnTopReplica que já esteja aberto.
3. A pasta do ajudante.
4. `Program Files (x86)\OnTopReplica`, `Program Files\OnTopReplica` e `%LOCALAPPDATA%\Programs\OnTopReplica`.

Instalou em outro lugar? Defina `OTR_EXE` com o caminho completo do `.exe`, ou copie o ajudante para a pasta do OnTopReplica.

## Como funciona

O script marca cada janela do OnTopReplica como "janela de ferramenta" do Windows (`WS_EX_TOOLWINDOW`).
Esse tipo de janela não aparece na barra de tarefas nem no Alt-Tab, mas continua por cima das outras e deixando o clique passar.
O script não altera o OnTopReplica nem nenhum arquivo dele.

## Desinstalação

Dê dois cliques em `Desinstalar.bat`, na pasta do ajudante, e confirme com **S**. Ele:

- fecha o ajudante e as réplicas abertas;
- apaga os atalhos "Fraiker Tools" do Menu Iniciar, da Área de Trabalho, da pasta e da inicialização do Windows (desliga o **Iniciar com o Windows**);
- apaga os arquivos do ajudante (`Fraiker Tools.ps1`, `Fraiker Tools.vbs`, `README.md`, `LICENSE`, a pasta `assets`) e o próprio `Desinstalar.bat`.

A pasta e o seu `Abrir réplicas.bat` ficam, com o seu layout. Outros arquivos que você tenha posto na pasta não são tocados.
Depois, se quiser, apague a pasta.

O OnTopReplica é outro programa: desinstale pelo Windows (Configurações → Aplicativos), se quiser.

## Aviso: regras do Tibia

Faz parte do **Fraiker Tools**. Este projeto não tem ligação com o OnTopReplica nem com a CipSoft/Tibia.

- **O que a ferramenta faz:** só **mostra** uma parte da tela do jogo em outro lugar. Não lê a memória do jogo, não altera o cliente, não clica e não digita nada.
- **O que as regras dizem:** a regra 3b das [Tibia Rules](https://www.tibia.com/support/?subtopic=tibiarules) proíbe "manipulating the official client program or using additional software to play the game". As regras não falam de overlays nem de espelhamento de tela.
- **O que não se sabe:** a CipSoft nunca se pronunciou sobre o OnTopReplica nem sobre ferramentas parecidas. Também não achamos relato de banimento. Para programas externos em geral, o suporte costuma responder que não são ilegais, mas não têm suporte ("por sua conta e risco").
- **Nunca ligue o "click forwarding" do OnTopReplica.** Ele repassa cliques da réplica para o jogo, e aí a ferramenta deixa de ser só tela. Use apenas `--clickThrough`, como no exemplo.
- **Quer certeza?** Abra um ticket no [suporte do Tibia](https://www.tibia.com/support/) e pergunte por escrito.

**Use por sua conta e risco.**

## Licença

[MIT](LICENSE): pode usar, copiar, modificar e redistribuir, desde que mantenha o aviso de autoria (Fraiker) e o texto da licença.
Se fizer uma versão própria, cite este projeto com o link do repositório.

O OnTopReplica tem licença própria: veja o repositório dele.
