from fastapi import FastAPI,status,HTTPException,Depends
import schemas
from sqlalchemy.orm import Session
import models
import database


app = FastAPI()

models.database.Base.metadata.create_all(database.engine)

@app.post("/blog",status_code=status.HTTP_201_CREATED)
def create_blog(request: schemas.Blog,db:Session = Depends(database.get_db)):
    blogs = models.Blog(title = request.title,body = request.body)
    db.add(blogs)
    db.commit()
    db.refresh(blogs)
    return blogs
@app.put("/blog/{id}" ,status_code=status.HTTP_202_ACCEPTED)
def update_blog(id,request: schemas.Blog, db: Session = Depends(database.get_db)):
    blog = db.query(models.Blog).filter(models.Blog.id == id)
    if not blog.first():
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,detail=f"blog with id {id} not found")
    blog.update(request.model_dump())
    db.commit()
    return "instance updated"

@app.delete("/blog/{id}",status_code=status.HTTP_204_NO_CONTENT)
def delete_blog(id,db:Session = Depends(database.get_db)):
    blog = db.query(models.Blog).filter(models.Blog.id == id)
    if not blog.first():
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,detail=f"blog with id {id} not found")
    blog.delete()
    db.commit()
    return "instance deleted"

   

@app.get("/blog")
def get_blog(db:Session = Depends(database.get_db)):
    blogs = db.query(models.Blog).all()
    return blogs



