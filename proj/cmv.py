# Flask app for MPCS Databases Class
# Julian McClellan
# Changemyview app

# Need 8 to 10 functions
# 1. Browse CMV Submissions
# 2. View CMV Submission (has CMV specific info)
# 2. View normal Submission
# 3. Search CMV Submissions by word
# 4. View Submissions between a certain date
# 5. View authors who used a word in a CMV submission and a previous
# submission
# 6. View CMV author history
# 7. View CMV moderator history
# 8. View individual comments

from flask import Flask, render_template, redirect, url_for
from flaskext.markdown import Markdown
from flaskext.mysql import MySQL

# Form imports
from flask_wtf import FlaskForm
from wtforms import SelectField, SubmitField, BooleanField
from wtforms.validators import DataRequired
from flask_wtf.csrf import CSRFProtect
import os


app = Flask(__name__)
md = Markdown(app)
mysql = MySQL()

app.config['MYSQL_DATABASE_HOST'] = 'mpcs53001.cs.uchicago.edu'
app.config['MYSQL_DATABASE_USER'] = 'jmcclellan'
app.config['MYSQL_DATABASE_PASSWORD'] = 'udaeTh5b'
app.config['MYSQL_DATABASE_DB'] = 'jmcclellanDB'
mysql.init_app(app)
app.secret_key = os.urandom(12)
CSRFProtect(app)

cur = mysql.connect().cursor()

cur.execute("SELECT DISTINCT subreddit FROM Submission;")
SUB_SUBREDDITS = [(tup[0], tup[0]) for tup in cur.fetchall()]
SUB_SUBREDDITS.append(("r/changemyview", "r/changemyview"))
SUB_SUBREDDITS.sort(key=lambda x: x[0])

cur.execute("SELECT DISTINCT subreddit FROM STD_Comment;")
COM_SUBREDDITS = [(tup[0], tup[0]) for tup in cur.fetchall()]
COM_SUBREDDITS.append(("r/changemyview", "r/changemyview"))
COM_SUBREDDITS.sort(key=lambda x: x[0])

cur.execute("SELECT DISTINCT user_name FROM CMV_Sub_Author;")
CMV_SUB_AUTHS = list(cur.fetchall())
CMV_SUB_AUTHS = {name[0]: True for name in CMV_SUB_AUTHS}

app.jinja_env.globals['CMV_SUB_AUTHS'] = CMV_SUB_AUTHS

del cur

class FilterSubmissions(FlaskForm):
    subreddit = SelectField('subreddit', choices=SUB_SUBREDDITS, default="r/changemyview",
            description="View Submissions from Another Subreddit")
    submit = SubmitField("View New Submissions")

class FilterComs(FlaskForm):
    subreddit = SelectField('subreddit', choices=COM_SUBREDDITS, default="r/changemyview",
            description="View comments from another subreddit")
    submit = SubmitField("View New Comments")

class ModComsOnly(FlaskForm):
    submit = SubmitField("r/changemyview moderator comments only")

@app.route('/')
def index():
    return redirect(url_for('hello'))

@app.route('/hello/')
@app.route('/hello/<name>')
def hello(name=None):
    return render_template('hello.html', name=name)


@app.route('/browse_subs', methods=('GET', 'POST'))
@app.route('/browse_subs/r/<subreddit>', methods=('GET', 'POST'))
@app.route('/browse_subs/r/<subreddit>/<author>', methods=('GET', 'POST'))
def browse_subs(subreddit=None, author=None):
    cur = mysql.connect().cursor()
    form = FilterSubmissions()
    if form.validate() or subreddit:
        if subreddit:
            # Get subreddits working
            subreddit = "r/" + subreddit
        else:
            subreddit = form.data["subreddit"]

        if subreddit == "r/changemyview":
            query = "SELECT title, from_unixtime(date_utc) date, author, total_comments, deltas_from_author"\
                    ", reddit_id, subreddit "\
                    "FROM CMV_Submission "
            if author:
                query += "WHERE author = %s"
            query += ";"
            cur.execute(query, [author])
            cmv_subs = cur.fetchall()
            other_subs = None
        else:
            form.subreddit.default = subreddit
            query = "SELECT title, from_unixtime(date_utc) date, author, total_comments, reddit_id  "\
                    "FROM Submission WHERE subreddit = %s "
            if author:
                query += "AND author = %s;"
                cur.execute(query, [subreddit, author]) 
            else:
                cur.execute(query, [subreddit])
            other_subs = cur.fetchall() 
            cmv_subs = None
    else:
        form = FilterSubmissions()
        query = "SELECT title, from_unixtime(date_utc) date, author, total_comments, deltas_from_author"\
                ", reddit_id, subreddit "\
                "FROM CMV_Submission;"
        cur.execute(query)
        cmv_subs = cur.fetchall()
        other_subs = None
    return render_template('browse_subs.html', cmv_subs=cmv_subs, form=form, other_subs=other_subs)

@app.route('/browse_coms', methods=('GET', 'POST'))
@app.route('/browse_coms/r/<subreddit>', methods=('GET', 'POST'))
@app.route('/browse_coms/r/<subreddit>/<author>', methods=('GET', 'POST'))
def browse_coms(subreddit=None, author=None):
    cur = mysql.connect().cursor()
    form = FilterComs()
    mod_form = ModComsOnly()
    if form.validate() or subreddit:
        if subreddit:
            # Get subreddits working
            subreddit = "r/" + subreddit
            form.subreddit.default = subreddit
        else:
            subreddit = form.data["subreddit"]

        if subreddit == "r/changemyview":
            query = "SELECT s.reddit_id, s.title, c.score, from_unixtime(c.date_utc) date, c.reddit_id, c.author, c.subreddit, c.edited"\
                ", c.content, c.parent_submission_id, c.replies, c.author_children, c.total_children, "\
                "c.unique_repliers, c.parent_comment_id, c.deltas_from_other, c.deltas_from_op "\
                "FROM CMV_Comment c "\
                "JOIN CMV_Submission s "\
                "ON c.parent_submission_id = s.reddit_id "
            if author:
                query += "WHERE c.author = %s"
                query += ";"
                cur.execute(query, [author])
            else:
                cur.execute(query)
            cmv_coms = cur.fetchall()
            other_coms = None
        else:
            form.subreddit.default = subreddit
            #                  0                                 1        2          3       4               5
            #       5                  6             7                 8             9     
            #           10                   11
            query = "SELECT c.score, from_unixtime(c.date_utc) date, c.reddit_id, c.author, c.subreddit, c.edited"\
            ", c.content, c.parent_submission_id, c.replies, c.author_children, c.total_children, "\
            "c.unique_repliers, c.parent_comment_id "\
            "FROM STD_Comment c "\
            "WHERE c.subreddit = %s"
            if author:
                query += "AND author = %s"
                cur.execute(query, [subreddit, author]) 
            else:
                cur.execute(query, [subreddit])
            other_coms = cur.fetchall() 
            cmv_coms = None
    else:
        form = FilterComs()
        query = "SELECT s.reddit_id, s.title, c.score, from_unixtime(c.date_utc) date, c.reddit_id, c.author, c.subreddit, c.edited"\
        ", c.content, c.parent_submission_id, c.replies, c.author_children, c.total_children, "\
        "c.unique_repliers, c.parent_comment_id, c.deltas_from_other, c.deltas_from_op "\
        "FROM CMV_Comment c "\
        "JOIN CMV_Submission s "\
        "ON c.parent_submission_id = s.reddit_id "
        cur.execute(query)
        cmv_coms = cur.fetchall()
        other_coms = None
    return render_template('browse_coms.html', cmv_coms=cmv_coms,
            form=form, other_coms=other_coms, mod_form=mod_form)

@app.route('/browse_cmv_mod_coms')
def browse_cmv_mod_coms():
    cur = mysql.connect().cursor()
    query = "SELECT c.score, from_unixtime(c.date_utc) date, c.reddit_id, c.author, c.subreddit, c.edited"\
    ", c.content, c.parent_submission_id, c.replies, c.author_children, c.total_children, "\
    "c.unique_repliers, c.parent_comment_id "\
    "FROM CMV_Mod_Comment c "

    cur.execute(query)
    mod_coms = cur.fetchall()

    return render_template('browse_cmv_mod_coms.html', mod_coms=mod_coms)

# Submission Viewing

@app.route('/view_cmv_sub/<reddit_id>')
def view_cmv_sub(reddit_id):
    cur = mysql.connect().cursor()
    query = "SELECT title, from_unixtime(date_utc) date, author, total_comments, deltas_from_author, "\
            "edited, content, direct_comments, author_comments, unique_commentors, deltas_from_other, "\
            "cmv_mod_comments, score, reddit_id FROM CMV_Submission WHERE reddit_id = %s;"
    cur.execute(query, [reddit_id])
    cmv_sub = cur.fetchall()[0]

    dcom_query = "SELECT score, date_utc, reddit_id, author, edited, content, "\
            "replies, deltas_from_other, deltas_from_other FROM CMV_Comment "\
            "WHERE CMV_Comment.parent_submission_id = %s AND CMV_Comment.parent_comment_id IS NULL ORDER BY deltas_from_op DESC;"
    cur.execute(dcom_query, [reddit_id])
    dcoms = cur.fetchall()
    return render_template('view_cmv_sub.html', cmv_sub=cmv_sub, direct_coms=dcoms)


@app.route('/view_sub/<reddit_id>')
def view_sub(reddit_id):
    cur = mysql.connect().cursor()
            #         0                              1       2         3
            # 4         5         6                  7               8 
            # 9        10        
    query = "SELECT title, from_unixtime(date_utc) date, author, total_comments, "\
            "edited, content, direct_comments, author_comments, unique_commentors, "\
            "score, reddit_id FROM Submission WHERE reddit_id = %s;"
    cur.execute(query, [reddit_id])
    sub = cur.fetchall()[0]

    dcom_query = "SELECT score, date_utc, reddit_id, author, edited, content, "\
            "replies FROM STD_Comment "\
            "WHERE STD_Comment.parent_submission_id = %s AND STD_Comment.parent_comment_id IS NULL"
    cur.execute(dcom_query, [reddit_id])
    dcoms = cur.fetchall()
    return render_template('view_sub.html', sub=sub, direct_coms=dcoms)


# Comment Viewing

@app.route('/view_cmv_com/<com_reddit_id>/<sub_reddit_id>')
def view_cmv_com(com_reddit_id, sub_reddit_id):
    cur = mysql.connect().cursor()
                    # 0                   1                  2          3      4         5
            # 6                 7        8                9                 10            11                  12              13 
    query = "SELECT score, from_unixtime(date_utc) date, reddit_id, author, edited, content, "\
    "parent_submission_id, replies, author_children, total_children, unique_repliers, parent_comment_id, deltas_from_other, deltas_from_op "\
    "FROM CMV_Comment WHERE CMV_Comment.reddit_id = %s"
    cur.execute(query, [com_reddit_id])
    cmv_com = cur.fetchall()[0]

    dreply_query = "SELECT score, from_unixtime(date_utc) date, reddit_id, author, edited, content, "\
            "replies, deltas_from_other, deltas_from_other FROM CMV_Comment "\
            "WHERE CMV_Comment.parent_submission_id = %s AND CMV_Comment.parent_comment_id = %s ORDER BY deltas_from_op DESC;"
    cur.execute(dreply_query, [sub_reddit_id, com_reddit_id])
    dreplies = cur.fetchall()

    psub_query = "SELECT title FROM CMV_Submission WHERE reddit_id = %s"
    cur.execute(psub_query, [sub_reddit_id])
    parent_sub = cur.fetchall()[0]

    return render_template('view_cmv_com.html', cmv_com=cmv_com, direct_replies=dreplies,
            parent_sub=parent_sub)

@app.route('/view_com/<com_reddit_id>')
def view_com(com_reddit_id):
    cur = mysql.connect().cursor()
                    # 0                   1                  2          3      4         5
            # 6                 7        8                9                 10            11             12
    query = "SELECT score, from_unixtime(date_utc) date, reddit_id, author, edited, content, "\
    "parent_submission_id, replies, author_children, total_children, unique_repliers, parent_comment_id, subreddit "\
    "FROM STD_Comment WHERE reddit_id = %s ;"
    cur.execute(query, [com_reddit_id])
    com = cur.fetchall()[0]

    return render_template('view_com.html', com=com)

@app.route('/view_cmv_mod_com/<com_reddit_id>')
def view_cmv_mod_com(com_reddit_id):
    cur = mysql.connect().cursor()
    query = "SELECT score, from_unixtime(date_utc) date, reddit_id, author, edited, content, "\
    "parent_submission_id, replies, author_children, total_children, unique_repliers, parent_comment_id, subreddit "\
    "FROM CMV_Mod_Comment WHERE reddit_id = %s ;"
    cur.execute(query, [com_reddit_id])
    com = cur.fetchall()[0]

    par_com_q = "SELECT reddit_id, author, content, parent_submission_id "\
    "FROM CMV_Comment WHERE reddit_id = %s ;"
    cur.execute(par_com_q, com[11])
    try:
        par_com = cur.fetchall()[0]
    except IndexError:
        par_com = None

    par_sub_q = "SELECT reddit_id, author, title "\
    "FROM CMV_Submission WHERE reddit_id = %s ;"
    cur.execute(par_sub_q, com[6])
    try:
        par_sub = cur.fetchall()[0]
    except IndexError:
        par_sub = None
    return render_template('view_cmv_mod_com.html', com=com,
            par_sub=par_sub, par_com=par_com)



# Author viewing

@app.route('/view_cmv_sub_author/<author_name>')
@app.route('/view_cmv_sub_author/<author_name>/<sub_reddit_id>')
@app.route('/view_cmv_sub_author/<author_name>/<com_reddit_id>')
def view_cmv_sub_author(author_name, sub_reddit_id=None, com_reddit_id=None):
    cur = mysql.connect().cursor()
    # Retrieve author stats
    auth_query = "SELECT user_name, submissions, comments, cmv_submissions, cmv_comments, deltas_awarded "\
            "FROM CMV_Sub_Author WHERE user_name = %s "
    cur.execute(auth_query, [author_name])
    auth = cur.fetchall()[0]

    # Retrieve Subreddit comment info
    com_info_query = "SELECT subreddit, COUNT(*) FROM STD_Comment WHERE author = %s GROUP BY subreddit"
    cur.execute(com_info_query, [author_name])
    coms_info = cur.fetchall()

    com_info_query = "SELECT subreddit, COUNT(*) FROM CMV_Comment WHERE author = %s GROUP BY subreddit"
    cur.execute(com_info_query, [author_name])
    cmv_coms_info = cur.fetchall()

    coms_info += cmv_coms_info

    # Retrieve Subreddit submission info
    sub_info_query = "SELECT subreddit, COUNT(*) FROM Submission WHERE author = %s GROUP BY subreddit"
    cur.execute(sub_info_query, [author_name])
    subs_info = cur.fetchall()

    sub_info_query = "SELECT subreddit, COUNT(*) FROM CMV_Submission WHERE author = %s GROUP BY subreddit"
    cur.execute(sub_info_query, [author_name])
    cmv_subs_info = cur.fetchall()

    subs_info += cmv_subs_info

    return render_template('view_cmv_sub_auth.html', auth=auth, coms_info=coms_info, subs_info=subs_info)

@app.route('/view_cmv_mod/<author_name>')
def view_cmv_mod(author_name):
    cur = mysql.connect().cursor()
    auth_query = "SELECT mod_name, cmv_comments, cmv_subs_commented_on FROM "\
            "CMV_Moderator WHERE mod_name = %s"
    cur.execute(auth_query, author_name)
    auth = cur.fetchall()[0]

    return render_template('view_cmv_mod.html', auth=auth)


# Subreddit browsing
@app.route('/browse_subreddits/')
def browse_subreddits():
    cur = mysql.connect().cursor()
    subreddits = [t[0] for t in set(SUB_SUBREDDITS + COM_SUBREDDITS)]
    return render_template('browse_subreddits.html', subreddits=subreddits)


@app.route('/view_subreddit/r/<subreddit>')
def view_subreddit(subreddit):
    cur = mysql.connect().cursor()
    subreddit = "r/" + subreddit

    # Get comment information
    if subreddit == "r/changemyview":
        com_count_query = "SELECT COUNT(*) FROM CMV_Comment"
        cur.execute(com_count_query)
        com_count = cur.fetchone()
    else:
        com_count_query = "SELECT COUNT(*) FROM STD_Comment WHERE subreddit = %s"
        cur.execute(com_count_query, subreddit)
        com_count = cur.fetchone()

    # Get submission information
    if subreddit == "r/changemyview":
        sub_count_query = "SELECT COUNT(*) FROM CMV_Submission"
        cur.execute(sub_count_query)
        sub_count = cur.fetchone()
    else:
        sub_count_query = "SELECT COUNT(*) FROM Submission WHERE subreddit = %s"
        cur.execute(sub_count_query, subreddit)
        sub_count = cur.fetchone()


    # Get submissions per author
    if subreddit == "r/changemyview":
        cur.execute("SELECT COUNT(*), author FROM CMV_Submission GROUP BY author")
        sub_author_counts = cur.fetchall() 
    else:
        cur.execute("SELECT COUNT(*), author FROM Submission WHERE subreddit = %s GROUP BY author",
                subreddit)
        sub_author_counts = cur.fetchall() 

    # Get comments per author
    if subreddit == "r/changemyview":
        cur.execute("SELECT COUNT(*), author FROM CMV_Comment GROUP BY author")
        com_author_counts = cur.fetchall() 
    else:
        cur.execute("SELECT COUNT(*), author FROM STD_Comment WHERE subreddit = %s GROUP BY author",
                subreddit)
        com_author_counts = cur.fetchall() 

    return render_template('view_subreddit.html', sub_count=sub_count, 
            com_count=com_count, subreddit=subreddit[2:], sub_author_counts=sub_author_counts,
            com_author_counts=com_author_counts)


# Redditor encounter viewing
class SelectRedditor(FlaskForm):
    redditor2 = SelectField('subreddit',
            description="Select the 2nd Redditor")
    submit = SubmitField("View Encounters")

def has_name(tup, name="feartrich"):
    cur = mysql.connect().cursor()
    t = [t[0] for t in tup if t[0] == name]
    t1 = [t[1] for t in tup if t[1] == name]

    if name in t or (name in t1):
        return True
    else:
        return False

@app.route('/view_encounters/<redditor1>', methods=['GET', 'POST'])
def view_encounters(redditor1=None, redditor2=None):
    cur = mysql.connect().cursor()
    form = SelectRedditor()
    # Get authors with encounters with redditor1
    com_auths_query = "SELECT redditor1, redditor2 FROM Redditor_Submission_Encounter "\
    "WHERE redditor2 = %s OR redditor1 = %s"
    cur.execute(com_auths_query, [redditor1, redditor1])
    com_auths = cur.fetchall() 
    sub_auths_query = "SELECT redditor1, redditor2 FROM Redditor_Comment_Encounter "\
    "WHERE redditor2 = %s OR redditor1 = %s"
    cur.execute(sub_auths_query, [redditor1, redditor1])
    sub_auths = cur.fetchall()

    if has_name(com_auths) or has_name(sub_auths):
        print(penis)

    # Extract all authors that aren't redditor1
    all_common_auths = [auth[0] for auth in com_auths if auth[0] != redditor1]
    all_common_auths += [auth[1] for auth in com_auths if auth[1] != redditor1]
    all_common_auths += [auth[0] for auth in sub_auths if auth[0] != redditor1]
    all_common_auths += [auth[1] for auth in sub_auths if auth[1] != redditor1]
    all_common_auths = [(auth, auth) for auth in set(all_common_auths)]
    all_common_auths.sort()

    form.redditor2.choices = all_common_auths

    if form.validate():
        form.redditor2.default = form.data["redditor2"]
        redditor2 = form.data["redditor2"]
        
        # Submissions in common
        sub_query = "SELECT s.title, s.reddit_id, s.subreddit FROM "\
                "Redditor_Submission_Encounter rse "\
                "JOIN Submission s ON rse.parent_submission_id = s.reddit_id "\
                "WHERE rse.redditor1 = %s AND rse.redditor2 = %s "\
                "OR rse.redditor1 = %s AND rse.redditor2 = %s;"
        cur.execute(sub_query, [redditor1, redditor2, redditor2, redditor1])
        common_subs = list(cur.fetchall())
        cmv_sub_query = "SELECT s.title, s.reddit_id, s.subreddit FROM "\
                "Redditor_Submission_Encounter rse "\
                "JOIN CMV_Submission s ON rse.parent_submission_id = s.reddit_id "\
                "WHERE rse.redditor1 = %s AND rse.redditor2 = %s "\
                "OR rse.redditor1 = %s AND rse.redditor2 = %s;"
        cur.execute(cmv_sub_query, [redditor1, redditor2, redditor2, redditor1])
        common_subs += list(cur.fetchall())
        if len(common_subs) == 0:
            common_subs = None

        # Comments in common
        com_query = "SELECT s.content, s.reddit_id, s.subreddit, s.parent_submission_id FROM "\
                "Redditor_Comment_Encounter rse "\
                "JOIN STD_Comment s ON rse.parent_comment_id = s.reddit_id "\
                "WHERE rse.redditor1 = %s AND rse.redditor2 = %s "\
                "OR rse.redditor1 = %s AND rse.redditor2 = %s;"
        cur.execute(com_query, [redditor1, redditor2, redditor2, redditor1])
        common_coms = list(cur.fetchall())
        cmv_com_query = "SELECT s.content, s.reddit_id, s.subreddit, s.parent_submission_id FROM "\
                "Redditor_Comment_Encounter rse "\
                "JOIN CMV_Comment s ON rse.parent_comment_id = s.reddit_id "\
                "WHERE rse.redditor1 = %s AND rse.redditor2 = %s "\
                "OR rse.redditor1 = %s AND rse.redditor2 = %s;"
        cur.execute(cmv_com_query, [redditor1, redditor2, redditor2, redditor1])
        common_coms += list(cur.fetchall())
        if len(common_coms) == 0:
            common_coms = None
    else:
        common_subs, common_coms = None, None
    return render_template('view_encounters.html', redditor1=redditor1, 
            redditor2=redditor2, common_subs=common_subs, 
            common_coms=common_coms, form=form)

if __name__ == "__main__":
    app.run()
