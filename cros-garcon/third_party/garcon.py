# (c) 2012-2014, Michael DeHaan <michael.dehaan@gmail.com>
# (c) 2017 Ansible Project
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

# Make coding more python3-ish
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = '''
    callback: garcon
    type: stdout
    short_description: Ansible screen output for cros-garcon package
    version_added: historical
    description:
        - This is the output callback used by the ansible-playbook command
        - triggered by garcon.
'''

from ansible.plugins.callback import CallbackBase
from ansible import constants as C


class CallbackModule(CallbackBase):
    '''
    Callback plugin which is used by ansible-playbook command triggered by
    cros-garcon. Prints custom messages to garcon alongside minimal callback
    plugin messages when new callback events are received.
    '''

    CALLBACK_VERSION = 1.0
    CALLBACK_TYPE = 'stdout'
    CALLBACK_NAME = 'garcon'

    MESSAGE_TO_GARCON_IDENTIFIER = "MESSAGE TO GARCON: "
    TASK_FAILED_MESSAGE = "TASK_FAILED"
    TASK_OK_MESSAGE = "TASK_OK"
    TASK_SKIPPED_MESSAGE = "TASK_SKIPPED"
    TASK_UNREACHABLE_MESSAGE = "TASK_UNREACHABLE"

    def _command_generic_msg(self, message_to_garcon, host, result, caption):
        ''' output the result of a command run '''

        buf = self.MESSAGE_TO_GARCON_IDENTIFIER + message_to_garcon + "\n"

        buf += "%s | %s | rc=%s >>\n" % (host, caption, result.get('rc', -1))
        buf += result.get('stdout', '')
        buf += result.get('stderr', '')
        buf += result.get('msg', '')

        return buf + "\n"

    # Redefines warnings handling of a base class so that they are printed to
    # stdout instead of stderr.
    def _handle_warnings(self, res):
        ''' display warnings, if enabled and any exist in the result '''
        if C.ACTION_WARNINGS:
            if 'warnings' in res and res['warnings']:
                for warning in res['warnings']:
                    self._display.display(warning)
                del res['warnings']
            if 'deprecations' in res and res['deprecations']:
                for warning in res['deprecations']:
                    self._display.display(**warning)
                del res['deprecations']

    def v2_runner_on_failed(self, result, ignore_errors=False):
        self._handle_exception(result._result)
        self._handle_warnings(result._result)

        self._display.display(
            self._command_generic_msg(self.TASK_FAILED_MESSAGE,
                                      result._host.get_name(), result._result,
                                      "FAILED"))

    def v2_runner_on_ok(self, result):
        self._clean_results(result._result, result._task.action)

        self._handle_warnings(result._result)

        if result._result.get('changed', False):
            state = 'CHANGED'
        else:
            state = 'SUCCESS'

        self._display.display(
            self._command_generic_msg(self.TASK_OK_MESSAGE,
                                      result._host.get_name(), result._result,
                                      state))

    def v2_runner_on_skipped(self, result):
        self._display.display(self.MESSAGE_TO_GARCON_IDENTIFIER +
                              self.TASK_SKIPPED_MESSAGE)

        self._display.display("%s | SKIPPED" % (result._host.get_name()))

    def v2_runner_on_unreachable(self, result):
        self._display.display(self.MESSAGE_TO_GARCON_IDENTIFIER +
                              self.TASK_UNREACHABLE_MESSAGE)

        self._display.display("%s | UNREACHABLE! => %s" %
                              (result._host.get_name(),
                               self._dump_results(result._result, indent=4)))

    def v2_on_file_diff(self, result):
        if 'diff' in result._result and result._result['diff']:
            self._display.display(self._get_diff(result._result['diff']))
