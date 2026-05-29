class AgentThreadsController < InertiaController
  def show
    agent = policy_scope(Agent).find(params[:agent_id])
    authorize agent, :show?
    thread = agent.email_threads.find(params[:id])
    messages = thread.email_messages.order(:created_at).map do |m|
      {
        id: m.id,
        direction: m.direction,
        from_email: m.from_email,
        to_emails: m.to_emails,
        subject: m.subject,
        text: m.text,
        received_at: m.received_at,
        delivered_at: m.delivered_at,
        created_at: m.created_at
      }
    end

    render inertia: {
      agent: { id: agent.id, name: agent.name, email_address: agent.email_address },
      thread: {
        id: thread.id,
        subject: thread.subject.presence || "(no subject)",
        participants: thread.participants,
        last_activity_at: thread.last_activity_at
      },
      messages: messages
    }
  end
end
