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
$('#btn_set_memory').on('click', () => {
    logger.info('Set memory data.')

    const insts = document.getElementById('inst').value
    const instList = insts.replace(/^\n/gm, '').split('\n')

    const psg = getProcessingInstance()
    psg.SetBinary( instList )

    fHasSetMemory = true

    dumpMem()
})

$('#btn_exec_phase').on('click', () => {
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

$('#btn_exec_inst').on('click', () => {
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

$('#btn_start_execution').on('click', async () => {
    getStateFromForm()

    const psg = getProcessingInstance()

    if ( ! fHasSetMemory ) {
        logger.error( "Memory data has not been set." )
        return
    }

    fExecInsts = true

    const interval = $('#inst_interval').val()        // 命令実行間隔
    const accel    = $('#inst_accel').val()           // まとめて実行する命令数
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

$('#btn_stop_execution').on('click', () => {
    logger.info('Stop execution')
    fExecInsts = false
})


$('#btn_simulator_reset').on('click', () => {
    logger.info('Registers and memory data on kuechip simulator is reset.')
    // シミュレータリセット
    const psg = getProcessingInstance()
    psg.ResetKueSim()

    // UI 上のレジスタ/メモリをリセット
    $('#Phase').val("0")
    $('#PC').val("0x0000")
    $('#IR').val("0x00")
    $('#SP').val("0x0000")
    $('#ACC').val("0x0000")
    $('#IX').val("0x0000")
    $('#MAR').val("0x0000")
    $('#CF').val("0")
    $('#VF').val("0")
    $('#NF').val("0")
    $('#ZF').val("0")
    $('#IBUF').val("0x00")
    $('#OBUF').val("0x00")
    $('#IBUF_RE').val("0")
    $('#OBUF_WE').val("0")
    $('#IBUF_FLG_CLR').val("0")

    $('mem').val('no memory data')
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
    state.pc  = parseInt(document.getElementById("PC"  ).value, 16)
    state.ir  = parseInt(document.getElementById("IR"  ).value, 16)
    state.sp  = parseInt(document.getElementById("SP"  ).value, 16)
    state.acc = parseInt(document.getElementById("ACC" ).value, 16)
    state.ix  = parseInt(document.getElementById("IX"  ).value, 16)
    state.mar = parseInt(document.getElementById("MAR" ).value, 16)

    state.flagCf = ( document.getElementById("CF").value === '1' )
    state.flagVf = ( document.getElementById("VF").value === '1' )
    state.flagNf = ( document.getElementById("NF").value === '1' )
    state.flagZf = ( document.getElementById("ZF").value === '1' )

    state.ibuf         = parseInt(document.getElementById("IBUF").value, 16)
    state.obuf         = parseInt(document.getElementById("OBUF").value, 16)
    state.ibuf_re      = ( document.getElementById("IBUF_RE"     ).value === '1' )
    state.obuf_we      = ( document.getElementById("OBUF_WE"     ).value === '1' )
    state.ibuf_flg_clr = ( document.getElementById("IBUF_FLG_CLR").value === '1' )
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
    document.getElementById("PC").value  = toHex(state.pc , 4)
    document.getElementById("IR").value  = toHex(state.ir , 2)
    document.getElementById("SP").value  = toHex(state.sp , 4)
    document.getElementById("ACC").value = toHex(state.acc, 4)
    document.getElementById("IX").value  = toHex(state.ix , 4)
    document.getElementById("MAR").value = toHex(state.mar, 4)

    document.getElementById("CF").value  = state.flagCf ? 1 : 0
    document.getElementById("VF").value  = state.flagVf ? 1 : 0
    document.getElementById("NF").value  = state.flagNf ? 1 : 0
    document.getElementById("ZF").value  = state.flagZf ? 1 : 0

    document.getElementById("IBUF").value         = toHex(state.ibuf, 2)
    document.getElementById("OBUF").value         = toHex(state.obuf, 2)
    document.getElementById("IBUF_RE").value      = state.ibuf_re      ? 1 : 0
    document.getElementById("OBUF_WE").value      = state.obuf_we      ? 1 : 0
    document.getElementById("IBUF_FLG_CLR").value = state.ibuf_flg_clr ? 1 : 0
}

function dumpMem() {
    const psg = getProcessingInstance()
    const state = psg.State()
    const memStr = []

    // 最後の有効データが存在する番地を調べる
    let lastIdx = 0
    for (let idx = 0xfffe / 2; idx >= 0; idx--) {
        if( state.mem[idx] !== 0 ) {
            lastIdx = idx
            break
        }
    }

    // 最後の有効データまでを出力形式に整形
    for (let idx = 0; idx <= lastIdx; idx++) {
        const current = state.currentInstAddr
        const styleBegin = ( idx * 2 === current ) ? '<div style="background: steelblue">' : '<div>'
        const styleEnd   = '</div>'
        memStr.push(
            styleBegin + toHex(idx * 2, 4) + " :  " + toHex(state.mem[idx], 4) + styleEnd
        )
    }

    // 結合して表示
    document.getElementById("mem").innerHTML = memStr.join('')
}

function dumpPhase() {
    const psg = getProcessingInstance()
    const state = psg.State()
    document.getElementById("Phase").value = state.phase
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
    document.getElementById("log").innerHTML += `[${hour}:${minute}] ${str}<br>`

    // 自動スクロール
    const logArea = document.getElementById("log")
    logArea.scrollTop = logArea.scrollHeight  // scroll to the bottom
}

