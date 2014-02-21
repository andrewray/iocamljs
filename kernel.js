//----------------------------------------------------------------------------
//  Copyright (C) 2008-2011  The IPython Development Team
//
//  Distributed under the terms of the BSD License.  The full license is in
//  the file COPYING, distributed as part of this software.
//----------------------------------------------------------------------------

// HACK HACK HACK HACK

//============================================================================
// Kernel
//============================================================================

/**
 * @module IPython
 * @namespace IPython
 * @submodule Kernel
 */

var IPython = (function (IPython) {

    var utils = IPython.utils;

    // Initialization and connection.
    /**
     * A Kernel Class to communicate with the Python kernel
     * @Class Kernel
     */
    var Kernel = function (base_url) {
        this.kernel_id = null;
        this.shell_channel = null;
        this.iopub_channel = null;
        this.stdin_channel = null;
        this.base_url = base_url;
        this.running = false;
        this.username = "username";
        this.session_id = utils.uuid();
        this._msg_callbacks = {};
        this.execution_count = 1;

        this.execute_context = null;

        if (typeof(WebSocket) !== 'undefined') {
            this.WebSocket = WebSocket;
        } else if (typeof(MozWebSocket) !== 'undefined') {
            this.WebSocket = MozWebSocket;
        } else {
            alert('Your browser does not have WebSocket support, please try Chrome, Safari or Firefox ≥ 6. Firefox 4 and 5 are also supported by you have to enable WebSockets in about:config.');
        };
    };


    Kernel.prototype._get_msg = function (msg_type, content) {
        var msg = {
            header : {
                msg_id : utils.uuid(),
                username : this.username,
                session : this.session_id,
                msg_type : msg_type
            },
            metadata : {},
            content : content,
            parent_header : {}
        };
        return msg;
    };

    /**
     * Start the Python kernel
     * @method start
     */
    Kernel.prototype.start = function (notebook_id) {
    };

    /**
     * Restart the python kernel.
     *
     * Emit a 'status_restarting.Kernel' event with
     * the current object as parameter
     *
     * @method restart
     */
    Kernel.prototype.restart = function () {
    };


    Kernel.prototype._kernel_started = function (json) {
    };


    Kernel.prototype._websocket_closed = function(ws_url, early) {
        this.stop_channels();
        $([IPython.events]).trigger('websocket_closed.Kernel', 
            {ws_url: ws_url, kernel: this, early: early}
        );
    };

    /**
     * Start the `shell`and `iopub` channels.
     * Will stop and restart them if they already exist.
     *
     * @method start_channels
     */
    Kernel.prototype.start_channels = function () {
    };

    /**
     * Start the `shell`and `iopub` channels.
     * @method stop_channels
     */
    Kernel.prototype.stop_channels = function () {
    };

    // Main public methods.

    /**
     * Get info on object asynchronoulsy
     *
     * @async
     * @param objname {string}
     * @param callback {dict}
     * @method object_info_request
     *
     * @example
     *
     * When calling this method pass a callbacks structure of the form:
     *
     *     callbacks = {
     *      'object_info_reply': object_info_reply_callback
     *     }
     *
     * The `object_info_reply_callback` will be passed the content object of the
     *
     * `object_into_reply` message documented in
     * [IPython dev documentation](http://ipython.org/ipython-doc/dev/development/messaging.html#object-information)
     */
    Kernel.prototype.object_info_request = function (objname, callbacks) {
        if(typeof(objname)!=null && objname!=null)
        {
            var content = {
                oname : objname.toString(),
            };
            var msg = this._get_msg("object_info_request", content);
            this.shell_channel.send(JSON.stringify(msg));
            this.set_callbacks_for_msg(msg.header.msg_id, callbacks);
            return msg.header.msg_id;
        }
        return;
    }

    /**
     * Execute given code into kernel, and pass result to callback.
     *
     * TODO: document input_request in callbacks
     *
     * @async
     * @method execute
     * @param {string} code
     * @param [callbacks] {Object} With the optional following keys
     *      @param callbacks.'execute_reply' {function}
     *      @param callbacks.'output' {function}
     *      @param callbacks.'clear_output' {function}
     *      @param callbacks.'set_next_input' {function}
     * @param {object} [options]
     *      @param [options.silent=false] {Boolean}
     *      @param [options.user_expressions=empty_dict] {Dict}
     *      @param [options.user_variables=empty_list] {List od Strings}
     *      @param [options.allow_stdin=false] {Boolean} true|false
     *
     * @example
     *
     * The options object should contain the options for the execute call. Its default
     * values are:
     *
     *      options = {
     *        silent : true,
     *        user_variables : [],
     *        user_expressions : {},
     *        allow_stdin : false
     *      }
     *
     * When calling this method pass a callbacks structure of the form:
     *
     *      callbacks = {
     *       'execute_reply': execute_reply_callback,
     *       'output': output_callback,
     *       'clear_output': clear_output_callback,
     *       'set_next_input': set_next_input_callback
     *      }
     *
     * The `execute_reply_callback` will be passed the content and metadata
     * objects of the `execute_reply` message documented
     * [here](http://ipython.org/ipython-doc/dev/development/messaging.html#execute)
     *
     * The `output_callback` will be passed `msg_type` ('stream','display_data','pyout','pyerr')
     * of the output and the content and metadata objects of the PUB/SUB channel that contains the
     * output:
     *
     * http://ipython.org/ipython-doc/dev/development/messaging.html#messages-on-the-pub-sub-socket
     *
     * The `clear_output_callback` will be passed a content object that contains
     * stdout, stderr and other fields that are booleans, as well as the metadata object.
     *
     * The `set_next_input_callback` will be passed the text that should become the next
     * input cell.
     */

    Kernel.prototype.send_stdout_message = function(message,where) {
        if (this.execute_context !== null && this.execute_context !== undefined) {
            var msg = this._get_msg("stream", {name: where, data: message});
            msg.parent_header = this.execute_context;
            this._handle_iopub_reply({data : JSON.stringify(msg)});
        }
    } 

    Kernel.prototype.execute = function (code, callbacks, options) {
        var that = this;
        var content = {
            code : code,
            silent : true,
            user_variables : [],
            user_expressions : {},
            allow_stdin : false
        };
        callbacks = callbacks || {};
        if (callbacks.input_request !== undefined) {
            content.allow_stdin = true;
        }
        $.extend(true, content, options)
        $([IPython.events]).trigger('execution_request.Kernel', {kernel: this, content:content});
        var request = this._get_msg("execute_request", content);
        this.set_callbacks_for_msg(request.header.msg_id, callbacks);
        
        this.execute_context = request.header;

        var r = null;
        var success = true;
        var save_console_log = console.log;
        console.log = function() {
            var data = ""
            for (var i = 0; i < arguments.length; i++) {
                if (i) data += " ";
                data += arguments[i];
            }
            data += "\n";
            var msg = that._get_msg("stream", {name: "stdout", data: data});
            msg.parent_header = request.header;
            that._handle_iopub_reply({data : JSON.stringify(msg)});
        }
        try {
            var res = iocaml.execute(this.execution_count, code);
            r = res.message;
            success = res.compilerStatus;
        } catch(err) {
            r = err; /* presumably a javscript exception */
            success = false;
        }
        console.log = save_console_log;

        var reply = this._get_msg("execute_reply", {
            status : "ok",
            execution_count: this.execution_count
        });
        reply.parent_header = request.header;
        var result = null;
        if (r !== null && r !== undefined) {
            if (success) {
                result = this._get_msg("pyout", {
                    execution_count: this.execution_count,
                    data : {
                        'text/plain' : "" + r
                    },
                    metadata : {}
                });
            } else if (!success){
                /*
                result = this._get_msg("pyerr", {
                    execution_count: this.execution_count,
                    ename : r.name,
                    evalue : r.message,
                    traceback : [r.stack]
                });
                */
                result = this._get_msg("pyout", {
                    execution_count: this.execution_count,
                    data : {
                        'text/html' : '<b><pre style="color:red">' + r + '</pre></b>'
                    },
                    metadata : {}
                });
            }
            result.parent_header = request.header;
            this._handle_iopub_reply({data : JSON.stringify(result)});
        }
        
        var idle = this._get_msg("status", {status: "idle"})
        idle.parent_header = request.header;
        
        this.execution_count = this.execution_count + 1;
        this._handle_iopub_reply({data : JSON.stringify(idle)});
        this._handle_shell_reply({data : JSON.stringify(reply)});
    };

    /**
     * When calling this method pass a callbacks structure of the form:
     *
     *      callbacks = {
     *       'complete_reply': complete_reply_callback
     *      }
     *
     * The `complete_reply_callback` will be passed the content object of the
     * `complete_reply` message documented
     * [here](http://ipython.org/ipython-doc/dev/development/messaging.html#complete)
     *
     * @method complete
     * @param line {integer}
     * @param cursor_pos {integer}
     * @param {dict} callbacks
     *      @param callbacks.complete_reply {function} `complete_reply_callback`
     *
     */
    Kernel.prototype.complete = function (line, cursor_pos, callbacks) {
        callbacks = callbacks || {};
        var content = {
            text : '',
            line : line,
            cursor_pos : cursor_pos
        };
        var msg = this._get_msg("complete_request", content);
        this.shell_channel.send(JSON.stringify(msg));
        this.set_callbacks_for_msg(msg.header.msg_id, callbacks);
        return msg.header.msg_id;
    };


    Kernel.prototype.interrupt = function () {
        if (this.running) {
            $([IPython.events]).trigger('status_interrupting.Kernel', {kernel: this});
            $.post(this.kernel_url + "/interrupt");
        };
    };


    Kernel.prototype.kill = function () {
        if (this.running) {
            this.running = false;
            var settings = {
                cache : false,
                type : "DELETE"
            };
            $.ajax(this.kernel_url, settings);
        };
    };

    Kernel.prototype.send_input_reply = function (input) {
        var content = {
            value : input,
        };
        $([IPython.events]).trigger('input_reply.Kernel', {kernel: this, content:content});
        var msg = this._get_msg("input_reply", content);
        this.stdin_channel.send(JSON.stringify(msg));
        return msg.header.msg_id;
    };


    // Reply handlers

    Kernel.prototype.get_callbacks_for_msg = function (msg_id) {
        var callbacks = this._msg_callbacks[msg_id];
        return callbacks;
    };


    Kernel.prototype.set_callbacks_for_msg = function (msg_id, callbacks) {
        this._msg_callbacks[msg_id] = callbacks || {};
    }


    Kernel.prototype._handle_shell_reply = function (e) {
        var reply = $.parseJSON(e.data);
        $([IPython.events]).trigger('shell_reply.Kernel', {kernel: this, reply:reply});
        var header = reply.header;
        var content = reply.content;
        var metadata = reply.metadata;
        var msg_type = header.msg_type;
        var callbacks = this.get_callbacks_for_msg(reply.parent_header.msg_id);
        if (callbacks !== undefined) {
            var cb = callbacks[msg_type];
            if (cb !== undefined) {
                cb(content, metadata);
            }
        };

        if (content.payload !== undefined) {
            var payload = content.payload || [];
            this._handle_payload(callbacks, payload);
        }
    };


    Kernel.prototype._handle_payload = function (callbacks, payload) {
        var l = payload.length;
        // Payloads are handled by triggering events because we don't want the Kernel
        // to depend on the Notebook or Pager classes.
        for (var i=0; i<l; i++) {
            if (payload[i].source === 'IPython.kernel.zmq.page.page') {
                var data = {'text':payload[i].text}
                $([IPython.events]).trigger('open_with_text.Pager', data);
            } else if (payload[i].source === 'IPython.kernel.zmq.zmqshell.ZMQInteractiveShell.set_next_input') {
                if (callbacks.set_next_input !== undefined) {
                    callbacks.set_next_input(payload[i].text)
                }
            }
        };
    };


    Kernel.prototype._handle_iopub_reply = function (e) {
        var reply = $.parseJSON(e.data);
        var content = reply.content;
        var msg_type = reply.header.msg_type;
        var metadata = reply.metadata;
        var callbacks = this.get_callbacks_for_msg(reply.parent_header.msg_id);
        if (msg_type !== 'status' && callbacks === undefined) {
            // Message not from one of this notebook's cells and there are no
            // callbacks to handle it.
            return;
        }
        var output_types = ['stream','display_data','pyout','pyerr'];
        if (output_types.indexOf(msg_type) >= 0) {
            var cb = callbacks['output'];
            if (cb !== undefined) {
                cb(msg_type, content, metadata);
            }
        } else if (msg_type === 'status') {
            if (content.execution_state === 'busy') {
                $([IPython.events]).trigger('status_busy.Kernel', {kernel: this});
            } else if (content.execution_state === 'idle') {
                $([IPython.events]).trigger('status_idle.Kernel', {kernel: this});
            } else if (content.execution_state === 'restarting') {
                $([IPython.events]).trigger('status_restarting.Kernel', {kernel: this});
            } else if (content.execution_state === 'dead') {
                this.stop_channels();
                $([IPython.events]).trigger('status_dead.Kernel', {kernel: this});
            };
        } else if (msg_type === 'clear_output') {
            var cb = callbacks['clear_output'];
            if (cb !== undefined) {
                cb(content, metadata);
            }
        };
    };


    Kernel.prototype._handle_input_request = function (e) {
        var request = $.parseJSON(e.data);
        var header = request.header;
        var content = request.content;
        var metadata = request.metadata;
        var msg_type = header.msg_type;
        if (msg_type !== 'input_request') {
            console.log("Invalid input request!", request);
            return;
        }
        var callbacks = this.get_callbacks_for_msg(request.parent_header.msg_id);
        if (callbacks !== undefined) {
            var cb = callbacks[msg_type];
            if (cb !== undefined) {
                cb(content, metadata);
            }
        };
    };


    IPython.Kernel = Kernel;

    return IPython;

}(IPython));

