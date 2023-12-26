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

CFG_DESC_CMD = 0 # scan-build -enable-checker debug.DumpCFG make 2> ./tmp.log
CFG_CMD = 1 # python ***/extract_scanbuild.py src_code/version/tmp.log  output_dir/version
FUN_CMD = 2 # python **/extract_func.py **/version  output_dir/version **/version

BASEDIR = "/code/DATA/RAW"
CFGDIR = "/code/DATA/CFG"
FUNDIR = "/code/DATA/FUN"

def handle_one_version(version_dir, versions, cmd, cmd_id=0):
    global lock
    global failed_versions
    while len(versions):
        lock.acquire()
        if len(versions) == 0: break
        cur_version = versions[0]
        versions.remove(cur_version)  # delete the version
        lock.release()
        print "Start: Thread-%s, Cmd:" % cur_version, cmd

        version_path = os.path.join(version_dir, cur_version)
        os.chdir(version_path)
        start = time.time()
        if cmd_id == CFG_DESC_CMD:
            ret = commands.getstatusoutput(cmd)
        elif cmd_id == CFG_CMD:
            log_path = os.path.join(version_path, 'tmp.log')
            output_ver_dir = version_path.replace('/code/DATA/RAW', '/code/DATA/CFG', 1)
            if not os.path.exists(output_ver_dir):
                os.makedirs(output_ver_dir)
            exe_cmd = "%s %s %s" % (cmd, log_path, output_ver_dir)
            print '++++++ ', exe_cmd 
            ret = commands.getstatusoutput(exe_cmd)
        elif cmd_id == FUN_CMD:
            output_ver_dir = version_path.replace('/code/DATA/RAW', '/code/DATA/FUN', 1)
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
            print "Success: Thread-%s, Cmd: %s" % (cur_version, cmd)
        time.sleep(1)

def main(extract_cfg_desc, extract_cfg, extract_fun, app_dir):
    config_cmd = "scan-build ./config"
    make_cmd = "scan-build -enable-checker debug.DumpCFG make 2> tmp.log"  # Generate CFG description using clang
    cfg_cmd = "python /code/VulDetector/DataPrepare/extract_cfg_desc.py " # Generate CFGs for each function
    func_cmd = "python /code/VulDetector/DataPrepare/extract_func.py " # Generate sourcecode for each function

    THREAD_CNT = 12
    def create_threads(cmds_args):
        threads = []
        for (app_dir, sub_dirs, cmd, cmd_id) in cmds_args:
            for i in range(THREAD_CNT):
                if len(sub_dirs) == 0:
                    break
                thread = threading.Thread(target=handle_one_version, args=(app_dir, sub_dirs, cmd, cmd_id))
                time.sleep(0.4)
                threads.append(thread)
                thread.start()    
        for thread in threads:
            thread.join()    

    if extract_cfg_desc == '1':
        create_threads([(app_dir, os.listdir(app_dir), config_cmd, CFG_DESC_CMD)])
        create_threads([(app_dir, os.listdir(app_dir), make_cmd, CFG_DESC_CMD)])
    thread_cmds = []
    if extract_cfg == '1':
        thread_cmds.append((app_dir, os.listdir(app_dir), cfg_cmd, CFG_CMD))
    if extract_fun == '1':
        thread_cmds.append((app_dir, os.listdir(app_dir), func_cmd, FUN_CMD))
    if thread_cmds:
        create_threads(thread_cmds)

if __name__ == "__main__":
    args = sys.argv[4:]
    for app in sys.argv[4:]:
        main(sys.argv[1], sys.argv[2], sys.argv[3], os.path.join(BASEDIR, app))
    print 'Finish'
    print failed_versions
    print len(failed_versions)
