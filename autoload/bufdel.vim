vim9script
# Name: autoload/bufdel.vim
# Author: Mao-Yining <mao.yining@outlook.com>
# Desc: Helps you delete buffers without changing windows layout.
# Derive From: wsdjeg's bufdel.nvim <https://github.com/wsdjeg/bufdel.nvim>
# Usage:
# import autoload "bufdel.vim"
#
# command! -nargs=* -bang -range -addr=buffers -complete=buffer Bdelete {
# 	bufdel.Delete(bufdel.CmdToBuffers({
# 		range: <range>,
# 		line1: <line1>,
# 		line2: <line2>,
# 		fargs: split(<q-args>),
# 		bang: <bang>false}),
# 	{ force: <bang>false, switch: 'lastused' })
# }
#
# command! -nargs=* -bang -range -addr=buffers -complete=buffer Bwipeout {
# 	bufdel.Delete(bufdel.CmdToBuffers({
# 		range: <range>,
# 		line1: <line1>,
# 		line2: <line2>,
# 		fargs: split(<q-args>),
# 		bang: <bang>false}),
# 	{ wipe: true, force: <bang>false, switch: 'lastused' })
# }

const switch_functions: dict<func(list<number>): number> = {
	lastused: (buffers: list<number>): number => {
		return getbufinfo({buflisted: 1})
			->filter((_, i) => buffers->index(i.bufnr) == -1)
			->sort((a, b) => b.lastused - a.lastused)
			->get(0, {bufnr: -1}).bufnr
	},
	alt: (_) => bufnr('#'),
	current: (_) => bufnr(),
	next: (buffers: list<number>): number => {
		sort(buffers)
		const buf = buffers[-1]
		const bufs = getbufinfo({buflisted: 1})->filter((_, t) => t.bufnr > buf)
		if len(bufs) >= 1
			return bufs[0].bufnr
		endif
		return -1
	},
	prev: (buffers: list<number>): number => {
		sort(buffers)
		const buf = buffers[0]
		const bufs = getbufinfo({buflisted: 1})->filter((_, t) => t.bufnr > buf)
		if len(bufs) >= 1
			return bufs[-1].bufnr
		endif
		return -1
	}
}

def DeleteBuf(buffers: list<number>, opt: dict<any>): void
	if len(buffers) == 0
		return
	endif

	var alt_buf: number
	const switch_type = opt->get("switch", v:none)->type()
	if switch_type == v:t_func
		alt_buf = opt.switch(buffers)
	elseif switch_type == v:t_string && switch_functions->has_key(opt.switch)
		alt_buf = switch_functions[opt.switch](buffers)
	elseif switch_type == v:t_number
		alt_buf = opt.switch
	elseif switch_type
		alt_buf = switch_functions.lastused(buffers)
	endif

	if !bufexists(alt_buf)
		alt_buf = bufnr('%')
	endif

	for buf in buffers
		for w in win_findbuf(buf)
			const [tabnr, winnr] = win_id2tabwin(w)
			if !tabnr->gettabwinvar(winnr, '&winfixbuf', false)
				win_execute(w, 'buffer ' .. alt_buf)
			endif
		endfor

		if !bufexists(buf)
			return
		endif

		if !opt->get('ignore_user_events', false) && exists('#User#BufDelPre')
			doautocmd User BufDelPre
		endif
		try
			if !opt->get('wipe', false)
				if opt.force
					execute "bdelete!" buf
				else
					execute "confirm bdelete" buf
				endif
				setbufvar(buf, '&buflisted', false)
			else
				if opt->get('force', false)
					execute "bwipeout!" buf
				else
					execute "confirm bwipeout" buf
				endif
			endif
		catch /^Vim(\a\+):E516:/
			return # Buffer was modified and delete was cancelled
		endtry

		if !opt->get('ignore_user_events', false) && exists('#User#BufDelPost')
			doautocmd User BufDelPost
		endif
	endfor
enddef

export def Delete(buf: any, opt: dict<any> = {}): void
	var del_bufs: list<number>

	if type(buf) == v:t_func
		const Buf = buf
		for v in getbufinfo({buflisted: true})
			if Buf(v.bufnr)
				del_bufs->add(v.bufnr)
			endif
		endfor
	elseif type(buf) == v:t_number
		del_bufs = [buf]
	elseif type(buf) == v:t_string
		const buf_nr = bufnr(buf)
		if buf_nr > 0
			del_bufs = [buf_nr]
		else
			del_bufs = RegexToBufs(buf)
		endif
	elseif type(buf) == v:t_list
		del_bufs = buf
	else
		return
	endif

	DeleteBuf(del_bufs, opt)
enddef

def RegexToBufs(regex: string): list<number>
	var buffers: list<number>
	for buf in getbufinfo({buflisted: true})
		if buf.name =~ regex
			buffers->add(buf.bufnr)
		endif
	endfor
	return buffers
enddef

export def CmdToBuffers(opt: dict<any>): list<number>
	var buffers: list<number>

	if opt.range == 0 && len(opt.fargs) == 0
		buffers->add(bufnr())
	endif

	if opt.range > 0
		const range = [str2nr(opt.line1), str2nr(opt.line2)]->sort()
		for buf in getbufinfo({buflisted: true})
			if buf.bufnr >= range[0] && buf.name <= range[1]
				buffers->add(buf.bufnr)
			endif
		endfor
	endif

	for b in opt.fargs
		const buf = str2nr(b)
		if buf != 0 && float2nr(buf) == buf
			buffers->add(buf)
		elseif bufnr(b) > 0
			buffers->add(bufnr(b))
		else
			for v in RegexToBufs(b)
				buffers->add(v)
			endfor
		endif
	endfor

	return buffers
enddef
