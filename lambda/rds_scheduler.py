import boto3
import logging
import os
import sys

TAG_KEY = os.getenv("TAG_KEY", "nightly")
TAG_VALUE = os.getenv("TAG_VALUE", "onoff")

rds = boto3.client("rds")


def setup():
    logger = logging.getLogger()

    for h in logger.handlers:
        logger.removeHandler(h)
    h = logging.StreamHandler(sys.stdout)

    FORMAT = "%(asctime)-15s [%(filename)s:%(lineno)d] :%(levelname)8s: %(message)s"
    h.setFormatter(logging.Formatter(FORMAT))
    logger.addHandler(h)
    logger.setLevel(logging.INFO)

    # Suppress the more verbose modules
    logging.getLogger("__main__").setLevel(logging.DEBUG)
    logging.getLogger("botocore").setLevel(logging.WARN)


def get_db_clusters(state):
    instances = rds.describe_db_clusters()["DBClusters"]
    for i in instances:
        # describe cluster does not come with tags
        instance_tags = rds.list_tags_for_resource(ResourceName=i["DBClusterArn"])[
            "TagList"
        ]
        i.update({"TagList": instance_tags})
    tagged_instances = [
        i["DBClusterIdentifier"]
        for i in instances
        if any(
            t["Key"] == TAG_KEY and t["Value"] == TAG_VALUE for t in i["TagList"]
        )
        and i["Status"] == state
    ]
    return tagged_instances


def get_db_instances(state):
    instances = rds.describe_db_instances()["DBInstances"]
    for i in instances:
        # describe instances does not come with tags
        instance_tags = rds.list_tags_for_resource(ResourceName=i["DBInstanceArn"])[
            "TagList"
        ]
        i.update({"TagList": instance_tags})
    tagged_instances = [
        i["DBInstanceIdentifier"]
        for i in instances
        if any(
            t["Key"] == TAG_KEY and t["Value"] == TAG_VALUE for t in i["TagList"]
        )
        and not i["Engine"].startswith("aurora")
        and i["DBInstanceStatus"] == state
    ]
    return tagged_instances


def stop_clusters():
    for instance_identifier in get_db_clusters("available"):
        logging.info("Stopping cluster: %s", instance_identifier)
        rds.stop_db_cluster(DBClusterIdentifier=instance_identifier)


def start_clusters():
    for instance_identifier in get_db_clusters("stopped"):
        logging.info("Starting cluster: %s", instance_identifier)
        rds.start_db_cluster(DBClusterIdentifier=instance_identifier)


def stop_rds():
    for instance_identifier in get_db_instances("available"):
        logging.info("Stopping rds: %s", instance_identifier)
        rds.stop_db_instance(DBInstanceIdentifier=instance_identifier)


def start_rds():
    for instance_identifier in get_db_instances("stopped"):
        logging.info("Starting rds: %s", instance_identifier)
        rds.start_db_instance(DBInstanceIdentifier=instance_identifier)


def stop_lambda_handler(event, context):
    setup()

    stop_clusters()
    stop_rds()


def start_lambda_handler(event, context):
    setup()

    start_clusters()
    start_rds()


if __name__ == "__main__":
    start_lambda_handler({}, {})
    stop_lambda_handler({}, {})
