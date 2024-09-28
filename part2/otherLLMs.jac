import:py from transformers {pipeline}
import:jac from rag {RagEngine}

# Define both LLMs: BLOOM and Flan-T5
glob bloom_generator = pipeline('text-generation', model='bigscience/bloom-1b7', device=-1, truncation=True, max_length=100); 
glob t5_generator = pipeline('text-generation', model='google/flan-t5-small');  

glob rag_engine:RagEngine = RagEngine();

node Session {
    has id: str;
    has chat_history: list[dict];
    has status: int = 1;

    # Function to choose between the two LLMs (BLOOM or Flan-T5)
    can llm_chat(
        message: str,
        chat_history: list[dict],
        agent_role: str,
        context: list,
        llm_choice: str = "bloom"  
    ) -> str {
        if llm_choice == "bloom" {
            response = bloom_generator(message, max_length=100);  
            return response[0]["generated_text"]; 
        }
        elif llm_choice == "flan" {
            response = t5_generator(message, max_length=100);  
            return response[0]["generated_text"];  
        }
    }
}

walker interact {
    has message: str;
    has session_id: str;
    has llm_choice: str = "bloom";  

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
            context=data,
            llm_choice=self.llm_choice  
        );

        here.chat_history.append({"role": "assistant", "content": response});
        report {"response": response};
    }
}
