from sys import stdin
import json

dic = json.load(fp=stdin)

items = dic["items"]
for item in items:
    url = item.get("html_url")
    language = item.get("language")
    print("{} {}".format(language, url))
    print("stargazers_count={}".format(item["stargazers_count"]))
    print("watchers={}".format(item["watchers"]))
    print("fork={}".format(item["forks"]))
    print("size={}".format(item["size"]))
    print("openIssues={}".format(item["open_issues"]))
    print("score={}".format(item["score"]))
    print("createdAt={}".format(item["created_at"]))
    print("updatedAt={}".format(item["updated_at"]))
    print("")
