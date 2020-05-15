'use strict'

var psg = null // processing instance

var fHasSetMemory = false

var state = {}

// ===== event handler =====
function setMem() {
    // get text in textarea 'inst'
    var insts = document.getElementById("inst").value
    var rgexp = new RegExp(/^\n/gm)
	var insts_no_blank = ( insts.replace(rgexp, "") )
    var instList = insts_no_blank.split('\n')

    getProcessingInstance()
    psg.SetBinary( instList )

    fHasSetMemory = true

    dumpMem()
}

function execPhase() { getStateFromForm(); update("phase"); dump() }
function execInst()  { getStateFromForm(); update("inst") ; dump() }
function execAll()   { getStateFromForm(); update("all")  ; dump() }


var fExecInsts = false

function execInsts() {
    fExecInsts = true;
    getStateFromForm();
    execInstsRecursively();
}

function stopExecuting() {
    fExecInsts = false
}


// ===== funtions =====
function execInstsRecursively() {

    if ( ! fExecInsts ) { return }

    for(var i = 0; i < 1000; i++) {
        update("inst")
        state = psg.State()         // instead of dump()
    }

    dump()
    
    setTimeout( () => { execInstsRecursively() }, 0 )
}


function update( mode ) {
    if ( ! fHasSetMemory ) {
        log( "Memory data has not been set." )
        return
    }

    // mode check
    if      ( mode === "phase" ) { /* log("Exec by 1 phase")               */ }
    else if ( mode === "inst"  ) { /* log("Exec by 1 inst")                */ }
    else if ( mode === "all"   ) { /* log("Exec all")                      */ }
    else                         {    log("internal error: invalid mode.")    }

    // call simulator
    getProcessingInstance()
    psg.Update(state, mode)        // (state, mode)
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
    state = psg.State()
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
    var state = psg.State()
    var memStr = []

    // 最後の有効データが存在する番地を調べる
    var lastIdx = 0
    for (var idx = 0xfffe / 2; idx >= 0; idx--) {
        if( state.mem[idx] !== 0 ) {
            lastIdx = idx
            break
        }
    }

    // 最後の有効データまでを出力形式に整形
    for (var idx = 0; idx <= lastIdx; idx++) {
        var current = state.currentInstAddr
        var styleBegin = ( idx * 2 === current ) ? '<span style="color: red">' : ''
        var styleEnd   = ( idx * 2 === current ) ? '</span>'                   : ''
        memStr.push(
            styleBegin + toHex(idx * 2, 4) + " :  " + toHex(state.mem[idx], 4) + styleEnd
        )
    }

    // 結合して表示
    document.getElementById("mem").innerHTML = memStr.join("<br>")
}

function dumpPhase() {
    var state = psg.State()
    document.getElementById("Phase").value = state.phase
}


function getProcessingInstance() {
    // get Processing instance
    if ( ! psg ) {
        psg = Processing.getInstanceById('kuesim')
        log( psg ?
             "Success to get instance of processing." :
             "Failed to get instance of processing."
           )
    }
}


// ========== utilities ==========
function pad0 ( value, digit ) {
    return ("000000000000" + value).slice(-1 * digit)
}

function toHex( value, digit ) {
    return "0x" + pad0(value.toString(16), digit)
}


// log
var logData = []
function log(str) {
    logData.push( str )
    document.getElementById("log").value = logData.join("\n")

    var logArea = document.getElementById("log")
    logArea.scrollTop = logArea.scrollHeight  // scroll to the bottom
}

