vim9script

set printfont=nsimsun:h12

set printoptions=header:0,paper:A4

if executable('ps2pdf')
	def Ps2Pdf(): number
		system($'ps2pdf {v:fname_in} {expand("%:p:r")}.pdf')
		return v:shell_error
	enddef
	set printexpr=s:Ps2Pdf()
endif

