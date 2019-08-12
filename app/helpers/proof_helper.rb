module ProofHelper
  def textify_proof_status(s)
    return case s
    when 'all'
      t(:total)
    when 'new'
      t(:proofstatus_new)
    when 'assigned'
      t(:proofstatus_assigned)
    when 'escalated'
      t(:proofstatus_escalated)
    when 'wontfix'
      t(:proofstatus_wontfix)
    when 'fixed'
      t(:proofstatus_fixed)
    when 'spam'
      t(:spam)
    end
  end
end
