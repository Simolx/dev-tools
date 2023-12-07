#-*- coding: utf-8 -*-

import json
import subprocess

def runCmd(cmd: str) -> (int , bytes, bytes):
    process = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    result, errorInfo = process.communicate()
    return process.returncode, result, errorInfo


def getPodsInfo(namespace: str='') -> list:
    podsInfo = []
    ns = '-A'
    if namespace and namespace.strip():
        ns = f'-n {namespace}'
    cmd = f'kubectl get pods -o json {ns}'
    returnCode, result, errorInfo = runCmd(cmd)
    if returnCode != 0:
        print(f'run cmd "{cmd}" failed, return code is {returnCode}, error message is:')
        print(errorInfo.decode('utf-8'))
    result = json.loads(result)
    for item in result['items']:
        podInfo = {'namespace': item['metadata']['namespace'], 'name': item['metadata']['name'], 'containers': []}
        spec = item['spec']
        containers = spec['containers']
        for container in containers:
            resources = container.get('resources', {})
            limits = resources.get('limits', {})
            requests = resources.get('requests', {})
            limitsCpu = limits.get('cpu', '0m')
            limitsMemory = limits.get('memory', '0Mi')
            requestsCpu = requests.get('cpu', '0m')
            requestsMemory  = requests.get('memory', '0Mi')
            podInfo['containers'].append({'limitsCpu': limitsCpu, 'limitsMemory': limitsMemory, 'requestsCpu': requestsCpu, 'requestsMemory': requestsMemory})
        podsInfo.append(podInfo)
    return podsInfo

if __name__ == '__main__':
    for podInfo in getPodsInfo():
        print(podInfo)