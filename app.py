from flask import Flask, render_template, redirect, url_for, flash, request
from flask_login import LoginManager, login_user, login_required, logout_user, current_user
from models import db, User, Review

app = Flask(__name__)
# Keep the secret key to allow flash messaging and sessions
app.config['SECRET_KEY'] = 'dev_secret_key_change_in_production'
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///feedops.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Initialize the db with the app
db.init_app(app)

# Set up Login Manager
login_manager = LoginManager()
login_manager.login_view = 'login'
login_manager.login_message_category = 'warning'
login_manager.init_app(app)

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

# Create database tables if they don't exist
with app.app_context():
    db.create_all()

@app.route('/')
def index():
    recent_reviews = Review.query.order_by(Review.timestamp.desc()).limit(3).all()
    return render_template('index.html', recent_reviews=recent_reviews)

@app.route('/review', methods=['GET', 'POST'])
@login_required
def review():
    if request.method == 'POST':
        movie_title = request.form.get('movie_title')
        review_text = request.form.get('review_text')
        rating = request.form.get('rating')
        
        if not rating or not review_text or not movie_title:
            flash('Please provide a movie title, a rating, and a review.', 'danger')
            return redirect(url_for('review'))
            
        new_review = Review(movie_title=movie_title, review_text=review_text, rating=int(rating), user_id=current_user.id)
        db.session.add(new_review)
        db.session.commit()
        
        flash('Thank you for your movie review!', 'success')
        return redirect(url_for('index'))
        
    return render_template('review.html')

@app.route('/admin')
@login_required
def admin():
    if current_user.username != 'admin':
        flash('Access denied. Admin privileges required.', 'danger')
        return redirect(url_for('index'))
        
    all_reviews = Review.query.order_by(Review.timestamp.desc()).all()
    return render_template('admin.html', reviews=all_reviews)


@app.route('/register', methods=['GET', 'POST'])
def register():
    if current_user.is_authenticated:
        return redirect(url_for('index'))
        
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        
        # Check if user exists
        user_exists = User.query.filter_by(username=username).first()
        if user_exists:
            flash('Username already exists.', 'danger')
            return redirect(url_for('register'))
            
        new_user = User(username=username)
        new_user.set_password(password)
        db.session.add(new_user)
        db.session.commit()
        
        flash('Registration successful! Please log in.', 'success')
        return redirect(url_for('login'))
        
    return render_template('register.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('index'))
        
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        
        user = User.query.filter_by(username=username).first()
        if user and user.check_password(password):
            login_user(user)
            flash('Logged in successfully.', 'success')
            next_page = request.args.get('next')
            return redirect(next_page or url_for('index'))
        else:
            flash('Invalid username or password.', 'danger')
            
    return render_template('login.html')

@app.route('/logout')
@login_required
def logout():
    logout_user()
    flash('You have been logged out.', 'info')
    return redirect(url_for('index'))

if __name__ == '__main__':
    # Run the Flask development server on all IP addresses of the machine
    app.run(host='0.0.0.0', port=5000, debug=True)
