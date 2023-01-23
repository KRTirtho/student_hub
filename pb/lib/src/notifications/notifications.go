package notifications

import (
	"fmt"

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

	user := comment.Expand()["user"].(*models.Record)
	post := comment.Expand()["post"].(*models.Record)

	if user.Id == post.GetString("user") {
		return nil
	}

	return nil
}

func OnPostCreation(app *pocketbase.PocketBase, e *core.RecordCreateEvent) error {

	return nil
}
func OnPostUpdate(app *pocketbase.PocketBase, e *core.RecordUpdateEvent) error {

	return nil
}
