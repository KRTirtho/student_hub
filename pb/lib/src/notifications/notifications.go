package notifications

import (
	"fmt"

	"github.com/pocketbase/dbx"
	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/core"
	"github.com/pocketbase/pocketbase/models"
)

var _ models.Model = (*Notification)(nil)

type Notification struct {
	models.BaseModel

	Collection string `db:"collection" json:"collection"`
	Record     string `db:"record" json:"record"`
	Message    string `db:"message" json:"message"`
	Viewed     bool   `db:"viewed" json:"viewed"`
	User       string `db:"user" json:"user"`
}

func (m *Notification) TableName() string {
	return "notifications"
}

func OnCommentCreation(app *pocketbase.PocketBase, e *core.RecordCreateEvent) error {
	context := e.HttpContext
	comment := e.Record
	apis.EnrichRecord(context, app.Dao(), comment, "user", "post")

	commentUser := comment.Expand()["user"].(*models.Record)
	post := comment.Expand()["post"].(*models.Record)

	if commentUser.Id == post.GetString("user") {
		return nil
	}

	message := fmt.Sprintf("%s commented on your post", commentUser.GetString("name"))

	if post.GetString("type") == "question" {
		message = fmt.Sprintf("%s answered your question", commentUser.GetString("name"))
	}

	notification := &Notification{
		Collection: "comments",
		Record:     comment.Id,
		Message:    message,
		Viewed:     false,
		User:       post.GetString("user"),
	}

	if err := app.Dao().Save(notification); err != nil {
		return err
	}

	return nil
}

func OnCommentUpdate(app *pocketbase.PocketBase, e *core.RecordUpdateEvent) error {
	context := e.HttpContext
	comment := e.Record
	apis.EnrichRecord(context, app.Dao(), comment, "user", "post")

	commentUser := comment.Expand()["user"].(*models.Record)
	post := comment.Expand()["post"].(*models.Record)

	apis.EnrichRecord(context, app.Dao(), post, "user")

	postUser := post.Expand()["user"].(*models.Record)

	if commentUser.Id == postUser.Id {
		return nil
	}

	authUser := context.Get("authRecord").(*models.Record)

	if authUser.Id != commentUser.Id && authUser.Id == postUser.Id && comment.GetBool("solve") {

		message := fmt.Sprintf("%s marked your answer as solve", postUser.GetString("name"))

		notification := &Notification{
			Collection: "comments",
			Record:     comment.Id,
			Message:    message,
			Viewed:     false,
			User:       commentUser.Id,
		}

		if err := app.Dao().Save(notification); err != nil {
			return err
		}
	}
	return nil
}

func OnPostCreation(app *pocketbase.PocketBase, e *core.RecordCreateEvent) error {
	context := e.HttpContext
	post := e.Record
	apis.EnrichRecord(context, app.Dao(), post, "user")
	if post.GetString("type") != "announcement" {
		return nil
	}

	postUser := post.Expand()["user"].(*models.Record)

	users, err := app.Dao().FindRecordsByExpr("users", dbx.Not(dbx.HashExp{"id": postUser.Id}))

	if err != nil {
		return err
	}

	for _, user := range users {
		notification := &Notification{
			Collection: "posts",
			Record:     post.Id,
			Message:    "There's a new announcement by " + postUser.GetString("name"),
			Viewed:     false,
			User:       user.Id,
		}

		if err := app.Dao().Save(notification); err != nil {
			return err
		}
	}

	return nil
}
func OnPostUpdate(app *pocketbase.PocketBase, e *core.RecordUpdateEvent) error {

	return nil
}
