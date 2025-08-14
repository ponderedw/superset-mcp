FROM apache/superset:4.1.1

USER root

RUN pip install psycopg2-binary Pillow

ENV ADMIN_PASSWORD $ADMIN_PASSWORD

COPY --chown=1001 ./superset-init.sh /superset-init.sh

COPY superset_config.py /app/
ENV SUPERSET_CONFIG_PATH /app/superset_config.py

ENTRYPOINT [ "/superset-init.sh" ]