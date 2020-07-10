'use strict'

let RT_CODES                    // return code (定数だけれど processing 側から取得)

let fHasSetMemory = false       // メモリセット済み
let fExecInsts    = false       // 実行中
let state = {}


// デバッグ用 コールスタック取得処理
Error.prepareStackTrace = (e, st) => ({
    'function':     st[0].getFunctionName(),
    'line':         st[0].getLineNumber(),
    'prevFunction': st[1].getFunctionName(),
    'prevLine':     st[1].getLineNumber(),
})

function getCallerInfo() {
    const buf = {}
    Error.captureStackTrace(buf, getCallerInfo)
    return buf.stack
}


// Processing のインスタンスを static local に持つクロージャ
const getProcessingInstance = (() => {
    let psg = null // processing instance

    return () => {
        if ( ! psg ) {
            psg = Processing.getInstanceById('kuesim')
            if ( psg ) {
                logger.info("Success to get the instance of processing.")
            }
        }

        return psg
    }
})()


const logger = {
    debug: (msg) => {
        return                  // 何も出力しない (コメントアウトでデバッグログ出力)

        let strCallerInfo = ''
        try {
            const caller = getCallerInfo()
            strCallerInfo = ` (${caller.prevFunction}:${caller.prevLine})`
        }
        catch(e) { /* JavaScriptStackTraceApi が使えない */ }

        _log(`[debug] ${msg}${strCallerInfo}`)
    },
    info:  (msg) => _log(`[info] ${msg}`),
    warn:  (msg) => _log(`[warn] ${msg}`),
    error: (msg) => _log(`[error] <span style="color: red">${msg}</style>`),
}


// ===== init =====
;(async () => {
    logger.info('Wait for initialization...')
    while( true ) {
        if ( getProcessingInstance() ) { break }
        await sleep(1 * 1000)
    }

    RT_CODES = (() => {
        const psg = getProcessingInstance()
        const rtCodes = psg.getReturnCodeConstans()
        return {
            CONTINUE: rtCodes.get('RT_CONTINUE'),
            DONE:     rtCodes.get('RT_DONE'),
            HLT:      rtCodes.get('RT_HLT'),
            ERROR:    rtCodes.get('RT_ERROR'),
        }
    })()

    logger.info('<span style="color: lightgreen">Initialization completed.</style>')
})()



// ===== event handler =====
// メモリデータが変更された時に set memory をハイライトする
$('#inst').on('keyup change', () => {
  $('#btn-set-memory').addClass('highlight')
})

$('#btn-set-memory').on('click', (e) => {
    logger.info('Set memory data.')

    $(e.target).removeClass('highlight')

    const insts = $('#inst').val()
    const instList = insts.replace(/^\n/gm, '').split('\n')

    const psg = getProcessingInstance()
    psg.SetBinary( instList )

    fHasSetMemory = true

    // 実行ボタンを無効状態を解除
    $('#btn-start-execution').prop('disabled', false)
    $('#btn-stop-execution' ).prop('disabled', false)
    $('#btn-exec-phase'     ).prop('disabled', false)
    $('#btn-exec-inst'      ).prop('disabled', false)

    dumpMem()
})

$('#btn-exec-phase').on('click', () => {
    getStateFromForm()
    const rtCode = update("phase")
    dump()

    if ( rtCode === RT_CODES.HLT ) { }
    else if ( rtCode === RT_CODES.CONTINUE || rtCode === RT_CODES.DONE ) {
        logger.info('Executed 1 phase')
    }
    else {
        logger.error('internal error in phase execution')
    }
})

$('#btn-exec-inst').on('click', () => {
    getStateFromForm()
    const rtCode = update("inst")
    dump()

    if ( rtCode === RT_CODES.HLT ) { }
    else if ( rtCode === RT_CODES.DONE ) {
        logger.info('Executed 1 instruction')
    }
    else {
        logger.error('internal error in instruction execution')
        logger.info(rtCode)
    }
})

$('#btn-start-execution').on('click', async () => {
    getStateFromForm()

    const psg = getProcessingInstance()

    if ( ! fHasSetMemory ) {
        logger.error( "Memory data has not been set." )
        return
    }

    fExecInsts = true

    const interval = $('#inst-interval').val()        // 命令実行間隔
    const accel    = $('#inst-accel').val()           // まとめて実行する命令数
                                                      // (マーチングとかを早くやる用)

    logger.info('Start execution.')

    while ( true ) {
        if ( ! fExecInsts ) { return }

        for(let i = 0; i < accel; i++) {
            if ( ! fExecInsts ) { break }

            const rtCode = update("inst")
            state = psg.State()         // instead of dump()

            // エラー or 終了チェック (実行状態の変更とログ出力は完了している. 状態表示を更新抜けるだけ)
            if ( rtCode == null || rtCode === RT_CODES.HLT ||  rtCode === RT_CODES.ERROR ) {
                break
            }
        }

        dump()
        await sleep(interval)
    }
})

$('#btn-stop-execution').on('click', () => {
    logger.info('Stop execution')
    fExecInsts = false
})


$('#btn-simulator-reset').on('click', () => {
    logger.info('Registers and memory data on kuechip simulator is reset.')
    fExecInsts = false

    // シミュレータリセット
    const psg = getProcessingInstance()
    psg.ResetKueSim()

    // UI 上のレジスタ/メモリをリセット
    $('#phase'        ).val("0")
    $('#pc'           ).val("0x0000")
    $('#ir'           ).val("0x00")
    $('#sp'           ).val("0x0000")
    $('#acc'          ).val("0x0000")
    $('#ix'           ).val("0x0000")
    $('#mar'          ).val("0x0000")
    $('#cf'           ).val("0")
    $('#vf'           ).val("0")
    $('#nf'           ).val("0")
    $('#zf'           ).val("0")
    $('#ibuf'         ).val("0x00")
    $('#obuf'         ).val("0x00")
    $('#ibuf-re'      ).val("0")
    $('#obuf-we'      ).val("0")
    $('#ibuf-flg-clr' ).val("0")
    $('#mem').html('no memory data')

    // 実行ボタンを無効状態に戻す
    $('#btn-start-execution').prop('disabled', true)
    $('#btn-stop-execution' ).prop('disabled', true)
    $('#btn-exec-phase'     ).prop('disabled', true)
    $('#btn-exec-inst'      ).prop('disabled', true)
})

// ===== funtions =====


function update( mode ) {
    if ( ! fHasSetMemory ) {
        logger.error( "Memory data has not been set." )
        return undefined
    }

    // mode check
    if      ( mode === "phase" ) { /* log("Exec by 1 phase")               */ }
    else if ( mode === "inst"  ) { /* log("Exec by 1 inst")                */ }
    else if ( mode === "all"   ) { /* log("Exec all")                      */ }
    else                         {    logger.error("internal error: Invalid execution mode.")    }

    // call simulator
    const psg = getProcessingInstance()
    const rtCode = psg.Update(state, mode)        // (state, mode)

    logger.debug(rtCode)
    if ( rtCode === RT_CODES.DONE ) {
        logger.debug('Instruction is done.')
    }
    else if ( rtCode === RT_CODES.CONTINUE ) {
        logger.debug('Instruction continues.')
    }
    else if ( rtCode === RT_CODES.HLT ) {
        logger.info('Finish execution.')
        fExecInsts = false
    }
    else { // RT_ERROR も含む
        logger.error('internal error')
        fExecInsts = false
    }
    return rtCode
}


function getStateFromForm() {
    // make associative array of KueState
    state.pc  = parseInt($('#pc' ).val(), 16)
    state.ir  = parseInt($('#ir' ).val(), 16)
    state.sp  = parseInt($('#sp' ).val(), 16)
    state.acc = parseInt($('#acc').val(), 16)
    state.ix  = parseInt($('#ix' ).val(), 16)
    state.mar = parseInt($('#mar').val(), 16)

    state.flagCf = ( $('#cf').val() === '1' )
    state.flagVf = ( $('#vf').val() === '1' )
    state.flagNf = ( $('#nf').val() === '1' )
    state.flagZf = ( $('#zf').val() === '1' )

    state.ibuf         = parseInt($('#ibuf').val(), 16)
    state.obuf         = parseInt($('#obuf').val(), 16)
    state.ibuf_re      = ( $('#ibuf-re'     ).val() === '1' )
    state.obuf_we      = ( $('#obuf-we'     ).val() === '1' )
    state.ibuf_flg_clr = ( $('#ibuf-flg-clr').val() === '1' )
}


function dump() {
    // dump simulator data
    dumpReg()
    dumpMem()
    dumpPhase()
}


function dumpReg() {
    const psg = getProcessingInstance()
    const state = psg.State()
    $('#pc' ).val(toHex(state.pc , 4))
    $('#ir' ).val(toHex(state.ir , 2))
    $('#sp' ).val(toHex(state.sp , 4))
    $('#acc').val(toHex(state.acc, 4))
    $('#ix' ).val(toHex(state.ix , 4))
    $('#mar').val(toHex(state.mar, 4))

    $('#cf').val( state.flagCf ? 1 : 0 )
    $('#vf').val( state.flagVf ? 1 : 0 )
    $('#nf').val( state.flagNf ? 1 : 0 )
    $('#zf').val( state.flagZf ? 1 : 0 )

    $('#ibuf'        ).val( toHex(state.ibuf, 2)       )
    $('#obuf'        ).val( toHex(state.obuf, 2)       )
    $('#ibuf-re'     ).val( state.ibuf_re      ? 1 : 0 )
    $('#obuf-we'     ).val( state.obuf_we      ? 1 : 0 )
    $('#ibuf-flg-clr').val( state.ibuf_flg_clr ? 1 : 0 )
}

function dumpMem() {
    const psg = getProcessingInstance()
    const state = psg.State()
    const memStr = []

  console.log(state.mem)

    // 最後の有効データが存在する番地を調べる
    let lastIdx = 0
    for (let idx = 0xfffe / 2; idx >= 0; idx--) {
        if( state.mem[idx] != null ) {
            lastIdx = idx
            break
        }
    }

    // 最後の有効データまでを出力形式に整形
    for (let idx = 0; idx <= lastIdx; idx++) {
        const current = state.currentInstAddr
        const styleBegin = ( idx * 2 === current ) ? '<div style="background: steelblue">' : '<div>'
        const styleEnd   = '</div>'

        const value = state.mem[idx] != null ? toHex(state.mem[idx], 4) : 'XXXXXX'
        memStr.push(
            styleBegin + toHex(idx * 2, 4) + " :  " + value + styleEnd
        )
    }

    // 結合して表示
    $('#mem').html( memStr.join('') )
}

function dumpPhase() {
    const psg = getProcessingInstance()
    const state = psg.State()
    $('#phase').val( state.phase )
}




// ========== utilities ==========
function sleep(msec) {
    return new Promise((r) => setTimeout(r, msec))
}

function pad0 ( value, digit ) {
    return value.padStart(digit, '0')
}

function toHex( value, digit ) {
    return "0x" + pad0(value.toString(16), digit)
}


// 内部用. 通常は logger.xxx を使う
function _log(str) {
  // developer tool への出力 (F12 等で確認)
  console.log(str)

  const now = new Date()
  const hour = now.getHours().toString().padStart(2, '0')
  const minute = now.getMinutes().toString().padStart(2, '0')

  // ログエリアへの出力
  $('.log').append(`[${hour}:${minute}] ${str}<br>`)

  // 自動スクロール
  $('.log').toArray().forEach((i) => {
    $(i).animate({scrollTop: i.scrollHeight}, 150)  // c.f. fast で 200 ms
  })
}
