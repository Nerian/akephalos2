# Reopen com.gargoylesoftware.htmlunit.ConfirmHandler to provide an interface to
# confirm a dialog and capture its message
module HtmlUnit
  module ConfirmHandler

    # Boolean - true for ok, false for cancel
    attr_accessor :handleConfirmValue

    # last confirmation's message
    attr_reader   :text

    # handleConfirm will be called by htmlunit on a confirm, so store the message.
    def handleConfirm(page, message)
      @text = message
      return handleConfirmValue.nil? ? true : handleConfirmValue
    end
  end
end