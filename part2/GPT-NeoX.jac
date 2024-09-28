import:py from transformers {pipeline}
import:jac from rag {RagEngine}


glob neox_generator = pipeline('text-generation', model='EleutherAI/gpt-neox-20b', device=-1, max_length=100, truncation=True);

glob rag_engine:RagEngine = RagEngine();

node Session {
    has id: str;
    has chat_history: list[dict];
    has status: int = 1;

    can llm_chat(
        message: str,
        chat_history: list[dict],
        agent_role: str,
        context: list
    ) -> str {
        response = neox_generator(message, max_length=100);  
        return response[0]["generated_text"];  
    }
}

walker interact {
    has message: str;
    has session_id: str;

    can init_session with `root entry {
        visit [-->](`?Session)(?id == self.session_id) else {
            session_node = here ++> Session(id=self.session_id, chat_history=[], status=1);
            print("Session Node Created");
            visit session_node;
        }
    }

    can chat with Session entry {
        here.chat_history.append({"role": "user", "content": self.message});
        data = rag_engine.get_from_chroma(query=self.message);
        response = here.llm_chat(
            message=self.message,
            chat_history=here.chat_history,
            agent_role="You are a conversation agent designed to help users with their queries based on the documents provided",
            context=data
        );

        here.chat_history.append({"role": "assistant", "content": response});
        report {"response": response};
    }
}
