FROM quay.io/containers/skopeo:latest

ENV HOME=/home/skopeo
WORKDIR ${HOME}

ADD bashrc /home/git/.bashrc

RUN mkdir /projects \
    # Store passwd/group as template files
    && cat /etc/passwd | sed s#root:x.*#root:x:\${USER_ID}:\${GROUP_ID}::\${HOME}:/bin/bash#g > ${HOME}/passwd.template \
    && cat /etc/group | sed s#root:x:0:#root:x:0:0,\${USER_ID}:#g > ${HOME}/group.template \
    # Change permissions to let any arbitrary user
    && for f in "${HOME}" "/etc/passwd" "/etc/group" "/projects"; do \
        echo "Changing permissions on ${f}" && chgrp -R 0 ${f} && \
        chmod -R g+rwX ${f}; \
    done
WORKDIR /projects

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD tail -f /dev/null