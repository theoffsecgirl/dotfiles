DOTFILES := $(shell pwd)
PACKAGES := runcom config bin

.PHONY: install macos test update clean edit help

install: ## Enlaza runcom/config/bin con stow e instala dependencias (brew bundle)
	stow -v -t $(HOME) $(PACKAGES)
	command -v brew >/dev/null 2>&1 && brew bundle --file=install/Brewfile || true

macos: ## Bootstrap completo de una Mac nueva (Homebrew + make install)
	bash macos/bootstrap-macos.sh

test: ## Corre la suite de tests (bats)
	bats test/

update: ## Actualiza Homebrew y re-aplica los symlinks de stow
	brew update
	brew upgrade
	stow -v -R -t $(HOME) $(PACKAGES)

clean: ## Elimina los symlinks creados por stow
	stow -v -D -t $(HOME) $(PACKAGES)

edit: ## Abre el repo de dotfiles en $EDITOR
	$${EDITOR:-nvim} $(DOTFILES)

help: ## Muestra esta ayuda
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'
