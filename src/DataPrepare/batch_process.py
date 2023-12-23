#!/bin/python

# =================================================================================
# Copyright 2020 IIE, CAS
#
# This file automatically processes the CFG generation, sourcecode generation from projects
# Input: the directory of projects file
#
# Author: Lei Cui
# Contact: cuilei@iie.ac.cn
#
# THIS CODE HAS BEEN MODIFIED BY ME
# PLEASE AVOID CONTACTING THE ORIGINAL AUTHOR IF THERE ARE ISSUES WITH THE CODE
# =================================================================================

import os
import sys
import time
import threading
import commands

lock = threading.Lock()
failed_versions = []

CFG_CMD = 0 # scan-build -enable-checker debug.DumpCFG make 2> ./tmp.log
GRAPH_CMD = 1 # python ***/extract_scanbuild.py src_code/version/tmp.log  output_dir/version
SMALL_FUNC_CMD = 2 # python **/extract_func.py **/version  output_dir/version **/version

INPUT_DIR = "/code/input/"
OUTPUT_DIR = "/code/output/"

def handle_one_version(version_dir, versions, cmd, cmd_id=0):
    global lock
    global failed_versions
    while len(versions):
        lock.acquire()
        if len(versions) == 0: break
        cur_version = versions[0]
        versions.remove(cur_version)  # delete the version
        lock.release()
        print "Thread-%s:" % cur_version, cmd

        version_path = os.path.join(version_dir, cur_version)
        os.chdir(version_path)
        start = time.time()
        if cmd_id == CFG_CMD:
            ret = commands.getstatusoutput(cmd)
        elif cmd_id == GRAPH_CMD:
            log_path = os.path.join(version_path, 'tmp.log')
            output_dir = os.path.join(OUTPUT_DIR, 'graphs')
            output_ver_dir = os.path.join(output_dir, cur_version)
            if not os.path.exists(output_ver_dir):
                os.makedirs(output_ver_dir)
            exe_cmd = "%s %s %s" % (cmd, log_path, output_ver_dir)
            print '++++++ ', exe_cmd 
            ret = commands.getstatusoutput(exe_cmd)
        elif cmd_id == SMALL_FUNC_CMD:
            output_dir = os.path.join(OUTPUT_DIR, 'small_funcs')
            output_ver_dir = os.path.join(output_dir, cur_version)
            if not os.path.exists(output_ver_dir):
                os.makedirs(output_ver_dir)
            exe_cmd = "%s %s %s %s" % (cmd, version_path, output_ver_dir, version_path)
            print '+++++++ ', exe_cmd
            ret = commands.getstatusoutput(exe_cmd)

        else:
            print 'Use formated cmd'

        end = time.time()
        #print "Version: %s, Time: %s" % (cur_version, end-start)
        if ret[0] != 0: 
            failed_versions.append(cur_version)
            print "Fail: Thread-%s, Cmd: %s, Ret: %s " % (cur_version, cmd, ret[0])
        else:
            print "Success: Thread-%s. Cmd: %s" % (cur_version, cmd)

        time.sleep(1)


def main(app_dir):
    print os.listdir(app_dir)

    config_cmd = "scan-build ./config"
    #test_cmd = "ls -l ./config"
    make_cmd = "scan-build -enable-checker debug.DumpCFG make 2> tmp.log"  # Generate CFG description using clang
    graph_cmd = "python /code/VulDetector/DataPrepare/extract_cfg_desc.py " # Generate CFGs for each function
    small_func_cmd = "python /code/VulDetector/DataPrepare/extract_func.py " # Generate sourcecode for each function

    THREAD_CNT = 12
    def create_threads(cmds_args):
        threads = []
        for (app_dir, sub_dirs, cmd, cmd_id) in cmds_args:
            for i in range(THREAD_CNT):
                if len(sub_dirs) == 0:
                    break
                #thread = threading.Thread(target=handle_one_version, args=(app_dir, sub_dirs, config_cmd, CFG_CMD) )
                #thread = threading.Thread(target=handle_one_version, args=(app_dir, sub_dirs, make_cmd, CFG_CMD) )
                #thread = threading.Thread(target=handle_one_version, args=(app_dir, sub_dirs, graph_cmd, GRAPH_CMD) )
                #thread = threading.Thread(target=handle_one_version, args=(app_dir, sub_dirs, small_func_cmd, SMALL_FUNC_CMD) )
                thread = threading.Thread(target=handle_one_version, args=(app_dir, sub_dirs, cmd, cmd_id))
                time.sleep(0.4)
                threads.append(thread)
                thread.start()    
        for thread in threads:
            thread.join()    
    create_threads([(app_dir, os.listdir(app_dir), config_cmd, CFG_CMD)])
    create_threads([(app_dir, os.listdir(app_dir), make_cmd, CFG_CMD)])
    create_threads([(app_dir, os.listdir(app_dir), graph_cmd, GRAPH_CMD), (app_dir, os.listdir(app_dir), small_func_cmd, SMALL_FUNC_CMD)])
    print 'Finish'
    print failed_versions
    print len(failed_versions)

if __name__ == "__main__":
    nums_of_args = len(sys.argv)
    if nums_of_args == 1:
        main(INPUT_DIR)
    elif nums_of_args == 2:
        main(sys.argv[1])
    else:
        print "batch_process.py <project directory>"
        exit(-1)
