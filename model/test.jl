using Agents

mutable struct User <: AbstractAgent
    id::Int
    pos::Int
    activity
    concentration
    quality_perception
end

function draw_activity()
    # from beta distribution
end

function draw_concentration()
    # from Poisson distribution
end

function draw_quality_vec()
    # some sort of multivariate distribution?
end

# quality vector
# evaluation space
# User.quality_perception ~ Post.quality




function get_opinion_distribution()
end

function get_evaluation_satisfaction()

end

mutable struct Post
    quality
    creation_time
    evaluation
    score
    views
    relevance
end


function compute_relevance(model, post, gravity)
    numerator = sum(post.quality)  
    denominator = (model.step - post.creation_time)^gravity
    return numerator / denominator
end




function quality_transformation(quality_vec)
    [1 / (1 + Base.MathConstants.e^(-0.5 * x)) for x in quality_vec]
end


function form_consensus_opinion(post, user)
    transformed_post_quality = quality_transformation(post.quality)
    transformed_quality_perception = quality_transformation(user.quality_perception)
    sum([x^y for (x, y) in zip(transformed_post_quality, transformed_quality_perception)]) / length(user.quality)
end

function form_dissent_opinion(post, user)
    q1 = quality_transformation(post.quality)
    q2 = quality_transformation(user.quality_perception)

    term = sqrt(sum([abs(i - j)^2 for (i, j) in zip(q1, q2)])) / length(q1)
    return 1 - term
end

q1 = [3, 4, 5]
q2 = [5, 1, 7]
term = sqrt(sum([abs(i - j)^2 for (i, j) in zip(q1, q2)])) / length(q1)


using Random 


properties = Dict()

ABM(User, scheduler = random_activation, properties = properties)

# number of Users
# number of initial Posts
# new Posts per iteration

