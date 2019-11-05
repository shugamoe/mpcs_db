# File for creating additional tuples of "CMV_Commentor"
import random, string
import pandas as pd
import numpy.random as npr

def randomword(length):
    letters = string.ascii_letters
    return ''.join(random.choice(letters) for i in range(length))


def main():
    """
    Creates random tuples for CMV_Moderator, CMV_Commentor, and
    CMV_Submission_Author
    """
    # CMV_Moderator
    usernames = [randomword(20) for i in range(10000)]
    subs_commented_on = npr.randint(1, 1000, 10000)
    num_coms = [npr.randint(0, num_subs) for num_subs in subs_commented_on]

    cmv_mod = pd.DataFrame({"mod_name": usernames, "cmv_comments": num_coms,
            "cmv_subs_commented_on": subs_commented_on})
    cmv_mod.columns = ["mod_name", "cmv_comments", "cmv_subs_commented_on"]
    cmv_mod.to_csv("cmv_mod.csv", index=False)

    # CMV_Commentor
    usernames = [randomword(20) for i in range(10000)]
    subs_commented_on = npr.randint(1, 1000, 10000)
    num_coms = [npr.randint(0, num_subs) for num_subs in subs_commented_on]

    cmv_com = pd.DataFrame({"user_name": usernames, "cmv_comments": num_coms,
            "cmv_subs_commented_on": subs_commented_on})
    cmv_com.columns = ["user_name", "cmv_comments", "cmv_subs_commented_on"]
    cmv_com.to_csv("cmv_commentor.csv", index=False)

    # CMV_Submission_Author
    usernames = [randomword(20) for i in range(10000)]
    submissions = npr.randint(2, 1000, 10000)
    comments = npr.randint(1, 3000, 10000)
    cmv_coms = [npr.randint(0, num_coms) for num_coms in comments]
    cmv_subs = [npr.randint(1, num_subs) for num_subs in submissions]
    deltas_from_author = [npr.randint(0, num_cmv_subs) for num_cmv_subs in cmv_subs]

    cmv_sub_auth = pd.DataFrame({"user_name": usernames,
            "submissions": submissions,
            "comments": comments,
            "cmv_submissions": cmv_subs,
            "cmv_comments": cmv_coms,
            "deltas_awarded": deltas_from_author})
    cmv_sub_auth.columns = ["user_name", "submissions", "comments",
            "cmv_submissions", "cmv_comments", "deltas_awarded"]
    cmv_sub_auth.to_csv("cmv_sub_auth.csv", index=False)


if __name__ == "__main__":
    main()
