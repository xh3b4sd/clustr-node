class exports.Channels
  channels:
    confirmation: () =>
      "confirmation"


    public: () =>
      "public"



    private: (pid) =>
      "private:#{pid}"



    group: (group) =>
      "group:#{group}"



    kill: (pid) =>
      "kill:#{pid}"



    registration: (pid) =>
      "registration:#{pid}"


    deregistration: (pid) =>
      "deregistration:#{pid}"



    clusterInfo: (pid) =>
      "clusterInfo:#{pid}"
