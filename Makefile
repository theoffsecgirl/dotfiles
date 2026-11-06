DOTFILES := $(shell pwd)
PACKAGES := runcom config bin

.PHONY: install macos test update link clean edit help check-folding

install: check-folding ## Enlaza runcom/config/bin con stow e instala dependencias (brew bundle)
	stow -v --no-folding -t $(HOME) $(PACKAGES)
	command -v brew >/dev/null 2>&1 && brew bundle --file=install/Brewfile || true

macos: ## Bootstrap completo de una Mac nueva (Homebrew + make install)
	bash macos/bootstrap-macos.sh

test: ## Corre la suite de tests (bats)
	bats test/

update: check-folding ## Actualiza Homebrew y re-aplica los symlinks de stow
	brew update
	brew upgrade
	stow -v --no-folding -R -t $(HOME) $(PACKAGES)

link: check-folding ## Re-aplica solo los symlinks de stow (tras un git pull)
	stow -v --no-folding -R -t $(HOME) $(PACKAGES)

clean: ## Elimina los symlinks creados por stow
	stow -v --no-folding -D -t $(HOME) $(PACKAGES)

# stow sin --no-folding convierte ~/.config o ~/.local en un enlace al repo
# y todo lo que escriben las apps (tokens, cachés, binarios) acaba aquí dentro.
check-folding:
	@for d in .config .local; do \
	  if [ -L "$(HOME)/$$d" ] && readlink "$(HOME)/$$d" | grep -q "$(notdir $(DOTFILES))"; then \
	    echo "ERROR: ~/$$d es un enlace al repo (stow lo ha plegado)."; \
	    echo "  Saca del repo lo no versionado (git status --ignored), borra el enlace,"; \
	    echo "  crea ~/$$d como carpeta real y repite make link."; \
	    exit 1; \
	  fi; \
	done

edit: ## Abre el repo de dotfiles en $EDITOR
	$${EDITOR:-nvim} $(DOTFILES)

help: ## Muestra esta ayuda
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'
