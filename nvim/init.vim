call plug#begin('~/.local/share/nvim/plugged')
	" coc
	Plug 'neoclide/coc.nvim', {'branch': 'release'}

	" helper
    Plug 'scrooloose/nerdcommenter'

    " vision 
	Plug 'vim-airline/vim-airline'
	Plug 'yggdroot/indentline'
	Plug 'jackguo380/vim-lsp-cxx-highlight'

    " theme
    Plug 'morhetz/gruvbox'
	Plug 'joshdick/onedark.vim'

call plug#end()

" basic vim {
	syntax on
	set nu
	set autoindent
	set smartindent
	set tabstop=4
	set softtabstop=4
	set shiftwidth=4
	set cursorline

	set background=dark
    colorscheme onedark
" }
" nvim {
	let g:python3_host_prog='~/.miniconda3/bin/python3'
" }
" window navigation {
    nmap gh <C-W>h
    nmap gj <C-W>j
    nmap gk <C-W>k
    nmap gl <C-W>l
"}
" terminal {
	tnoremap <ESC> <C-\><C-n>
	nmap <Leader>t :tabnew term://$SHELL<CR>i
	nmap <S-t> :bel vnew<CR>:vertical resize 60<CR>:term<CR>i
" }
" search {
    nnoremap <silent> <Leader>h <S-*>N
    nnoremap <silent> <Leader><Esc> :noh<CR>
" }
" { finance 
	function! Run_finance(code)
		let ret = execute("!~/.local/bin/currency ".a:code, "silent")
		let sp = split(ret, '\n')
		echo sp[2]
		echo sp[3]
		echo sp[4]
	endfunction

	:command! -nargs=* Finance call Run_finance(<args>)
    nnoremap <Leader>0 :call Run_finance('')<cr>
" }
" { airline
	call airline#parts#define_function('foo', 'CurrencyGet')
	let g:airline_section_x = airline#section#create_right(['foo'])
	"let g:airline_section_b = airline#section#create_left(["%{get(b:,'coc_git_status','')} %{get(g:,'coc_git_status','')}"])
	let g:airline_section_b = airline#section#create_left(["%{get(g:,'coc_git_status','')}"])
" }
" coc {
	autocmd FileType json syntax match Comment +\/\/.\+$+
	function! SetupCommandAbbrs(from, to)
		exec 'cnoreabbrev <expr> '.a:from
					\ .' ((getcmdtype() ==# ":" && getcmdline() ==# "'.a:from.'")'
					\ .'? ("'.a:to.'") : ("'.a:from.'"))'
	endfunction

	" Use C to open coc config
	call SetupCommandAbbrs('C', 'bel vnew <cr>:CocConfig')

	" use <tab> for trigger completion and navigate to the next complete item
	function! s:check_back_space() abort
		let col = col('.') - 1
		return !col || getline('.')[col - 1]  =~ '\s'
	endfunction

	inoremap <silent><expr> <Tab>
				\ pumvisible() ? "\<C-n>" :
				\ <SID>check_back_space() ? "\<Tab>" :
				\ coc#refresh()

	" Use <cr> to confirm completion
	inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

	" Remap keys for gotos
	nmap <silent> gd <Plug>(coc-definition)
	nmap <silent> gy <Plug>(coc-type-definition)
	nmap <silent> gi <Plug>(coc-implementation)
	nmap <silent> gr <Plug>(coc-references)

	" Remap for rename current word
	nmap <leader>rn <Plug>(coc-rename)
	" Remap keys for applying codeAction to the current line.
	nmap <leader>ac  <Plug>(coc-codeaction)
	" Apply AutoFix to problem on the current line.
	nmap <leader>qf  <Plug>(coc-fix-current)

	" Use K to show documentation in preview window
	nnoremap <silent> K :call <SID>show_documentation()<CR>
	function! s:show_documentation()
		if (index(['vim','help'], &filetype) >= 0)
			execute 'h '.expand('<cword>')
		else
			call CocAction('doHover')
		endif
	endfunction

	" Using CocList
	" Show commands
	nnoremap <silent> <Leader>x :<C-u>CocList commands<cr>
	" show diagnostics
	nnoremap <silent> <Leader>d :<C-u>CocList diagnostics<cr>
	" show vim commands
	nnoremap <silent> <Leader>v :<C-u>CocList vimcommands<cr>
	" match lines of current buffer"
	nnoremap <silent> <Leader>l  :<C-u>CocList lines<cr>
	" global search
	nnoremap <silent> <Leader>g  :<C-u>CocList grep<cr>
	" Find symbol of current document
	nnoremap <silent> <Leader>o  :<C-u>CocList outline<cr>
	" Show files 
	nnoremap <silent> <Leader>f  :<C-u>CocList files<cr>
	" Most  recent used
	nnoremap <silent> <Leader>b  :<C-u>CocList buffers<cr>

	" coc-actions
	" Remap for do codeAction of selected region
	function! s:cocActionsOpenFromSelected(type) abort
		execute 'CocCommand actions.open ' . a:type
	endfunction
	xmap <silent> <leader>a :<C-u>execute 'CocCommand actions.open ' . visualmode()<CR>
	nmap <silent> <leader>a :<C-u>set operatorfunc=<SID>cocActionsOpenFromSelected<CR>g@
" }
" { build c/c++
	function! Get_CMake_build_type()
		let cmake_cache = expand('$PWD/build/CMakeCache.txt')
		let type = "Debug"
		if filereadable(cmake_cache)
			let l:type = system("cat " . l:cmake_cache . " | grep CMAKE_BUILD_TYPE | awk -F'=' '{print$2}'")
		endif
		return l:type
	endfunction

    let cmake_build_type = Get_CMake_build_type()
	let with_extern_script = 1

	function! Set_extern_script(enable)
		let g:with_extern_script = a:enable
		echo 'extern_script '. g:with_extern_script
	endfunction

    :command! -nargs=1 ExternScript call Set_extern_script(<q-args>)

    function! Run_cmake(...)
		if a:0 > 0
			echo 'set cmake build type: ' . a:1
			let g:cmake_build_type = a:1
			:!rm -rf build
		endif

		let host = '.'
		if a:0 > 1
			let l:host = a:2
		endif
		echo "host ".l:host
		execute '!cmake -H'.l:host.' -Bbuild -GNinja -DCMAKE_EXPORT_COMPILE_COMMANDS=YES -DCMAKE_BUILD_TYPE=' . g:cmake_build_type
		
		if g:with_extern_script
			let extern_script = expand('$PWD/.vim/cmake_config.sh')
			if filereadable(extern_script)
				echo 'run external cmake config script'
				execute '!'.extern_script
			else
				echo extern_script . ' not exist'
			endif
		endif
    endfunction

    function! Run_build(...)
        :wa
		echo "CMake build type: " . g:cmake_build_type
		if a:0 == 1
			if a:1 == 1
				execute '!cmake --build build -- -j1'
			else
				execute '!cmake --build build -- ' .a:1
			endif
		else
			execute '!cmake --build build'
		endif

		if g:with_extern_script
			let extern_script = expand('$PWD/.vim/cmake_build.sh')
			if filereadable(extern_script)
				echo 'run external cmake build script'
				execute '!'.extern_script
			else
				echo extern_script . ' not exist'
			endif
		endif
    endfunction

    :command! -nargs=* CMake call Run_cmake(<f-args>)
    :command! -nargs=? Build call Run_build(<q-args>) 
    :command! -nargs=* LLDB :tabnew term://lldb -- <args>

    noremap <Leader>2 :call Run_cmake()<cr>
    nnoremap <Leader>3 :call Run_build()<cr>
"}


