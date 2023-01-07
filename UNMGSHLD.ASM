; MegaShield 1.0a/1.01a Unpacker
; Coded by dR.No // Delirium Tremens Group

model tiny
.code
.386

org 100h
Begin:
        mov     dx,offset Msg
        call    write
        mov     si,81h
        lodsb
        cmp     al,0Dh
        jne     FileOk
        mov     dx,offset Usage
        jmp     short write
FileOk:

        mov     cx,si

	push	si
@Str:
        mov     al,[si]
        cmp     al,0Dh
        je      _EndStr
        inc     si
        loop    @Str
_EndStr:
        mov     word ptr [si],2400h
	pop	si
        mov     dx,si
        mov     ax,3D02h
        int     21h
        jnc     NoErr
        mov     dx,offset not_found

Write:
        mov     ah,09
        int     21h
        ret
NoErr:
        xchg    bx,ax
        mov     dx,offset Process
        call    write
        mov     dx,si
        int     21h
        xor     cx,cx
        xor     dx,dx
        mov     ax,4200h
        int     21h
        mov     ah,3Fh
        mov     dx,offset Buf
        mov     cx,-1
        int     21h

        cmp     DWord Ptr Buf,0FFFFB890h
        jne     NotCrypt
	cmp	DWord Ptr Buf+4,0D23321E7h
	je	CryptOk

NotCrypt:
        mov     dx,offset NotCryptMes
        jmp     short write

CryptOk:
	dec	ah
        mov     di,ax
        xchg    cx,ax
        push    cx
        mov     ah,3Eh
        int     21h

	inc 	dh
        mov     si,dx
        push    si

        pusha

	mov	ax,di
	xor	dx,dx
	mov	bx,2
	div	bx
	add	ax,dx
	xchg	cx,ax


	mov	dx,1540h
	ror	dx,cl
	sub	dx,83BAh

	cmp	Byte Ptr Buf+0D8h,57h
	jne	Ver1_0
	xor 	dx,cx
	jmp	short @@@
Ver1_0:
        sub 	dx,4B89h
@@@:

	mov	di,offset Buf+100h

@Decode:
	mov	ax,[di]
	xor	ax,dx
	ror	ax,cl
	xor	ax,cx
	mov	[di],ax
	inc	di
	inc	di
        loop    @Decode

        popa

        mov     dx,offset _Out
        mov     ax,3C02h
        xor     cx,cx
        int     21h

        xchg    bx,ax

        pop     dx
        pop     cx
        mov     ah,40h
        int     21h

        mov     ah,3Eh
        int     21h
        mov     dx,offset Oki
        jmp     write
Msg             db              0dh,0ah,'MegaShield v1.0a/1.01a Unpacker coded by dR.No // ViP // DTg',0dh,0ah,24h
Usage           db              0dh,0ah,'Usage: UNCOMPRT <CRYPTFiLE>',0dh,0ah,24h
Not_found       db              'File not found',0dh,0ah,24h
NotCryptMes     db              0dh,0ah,'This file is not crypted with MegaShield',0dh,0ah,24h
Process         db              'Unpacking the file: $'
Oki             db              '... complete!',0dh,0ah,24h
_Out            db              'UNPACKED.COM',0
Buf:
End Begin